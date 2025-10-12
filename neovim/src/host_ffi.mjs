let _nvim = null;

// ----- Result helpers -----
const Ok = (v) => ({ type: "Ok", value: v });
const Error_ = (e) => ({ type: "Error", value: e });

// Normalize Node host / RPC / Lua errors into a simple string
function normalizeErr(err) {
  if (err && typeof err === "object") {
    const name = err.name || "Error";
    const msg  = err.message || String(err);
    const code = err.code != null ? ` code=${err.code}` : "";
    const data = err.data != null ? ` data=${JSON.stringify(err.data)}` : "";
    return `${name}: ${msg}${code}${data}`;
  }
  return String(err);
}

export function parse(v, d = {}) {
  if (v == null) return d;
  if (typeof v === "string") {
    try { return JSON.parse(v); } catch { return d; }
  }
  return v;
}

export function ensure() {
  if (!_nvim) throw new Error("plugin not initialized");
  return _nvim;
}

export function init(plugin) {
  if (!plugin || !plugin.nvim) throw new Error("plugin not initialized");
  _nvim = plugin.nvim;

  // Cache channel id for Gleam sync FFI calls
  try {
    _nvim.call("nvim_get_api_info", []).then(info => {
      if (Array.isArray(info) && Array.isArray(info[0])) {
        globalThis.__last_channel_id_cache = info[0][0] | 0;
      }
    }).catch(() => {});
  } catch (_) {}
}

async function safeCall(fn, ...args) {
  try {
    const res = await fn.apply(ensure(), args);
    return Ok(res ?? null);
  } catch (err) {
    return Error_(normalizeErr(err));
  }
}

// Commands / calls (Result forms)
export const command_r       = (t)       => safeCall(ensure().command, t);
export const call_function_r = (n, a=[]) => safeCall(ensure().call, n, a);

export const command       = (t)       => ensure().command(t);
export const call_function = (n, a=[]) => ensure().call(n, a);

export const out_write = (t) => ensure().outWrite(String(t) + "\n");

export const get_api_info_r = () => safeCall(ensure().call, "nvim_get_api_info", []);

export const get_channel_id_r = async () => {
  const got = await get_api_info_r();
  if (got.type === "Error") return got;
  const tuple = got[0];                 // payload from Result
  const chan = Array.isArray(tuple) ? tuple[0] : null;
  return chan == null ? Error_("nvim_get_api_info: no channel id") : Ok(chan | 0);
};

export async function exec_lua(code, args = []) {
  try {
    const result = await ensure().execLua(code, args);
    return Ok(result ?? null);
  } catch (err) {
    return Error_(normalizeErr(err));
  }
}

export function on_notification(cbName) {
  const n = ensure();
  if (typeof n.on !== "function") {
    throw new Error("nvim client lacks .on('notification', ...)");
  }
  const cb = (typeof cbName === "string" && globalThis[cbName]) || null;
  if (typeof cb !== "function") {
    throw new Error("on_notification: callback name not found on globalThis");
  }
  n.on("notification", (method, args) => {
    try {
      const payload = Array.isArray(args) ? args[0] : args;
      cb(method, payload);
    } catch (_) {}
  });
}

export const set_var = async (name, val) => {
  try { await ensure().call("nvim_set_var", [name, val]); return Ok(null); }
  catch (err) { return Error_(normalizeErr(err)); }
};
export const get_var = async (name) => {
  try { const v = await ensure().call("nvim_get_var", [name]); return Ok(v ?? null); }
  catch (err) { return Error_(normalizeErr(err)); }
};

export function scope_obj(s) {
  switch (s) {
    case "global": return { scope: "global" };
    case "window": return { scope: "local", win: 0 };
    case "buffer": return { scope: "local", buf: 0 };
    default: throw new Error("bad scope");
  }
}

export const set_option = (scope, name, val) =>
  ensure().call("nvim_set_option_value", [name, val, scope_obj(scope)]);
export const get_option = (scope, name) =>
  ensure().call("nvim_get_option_value", [name, scope_obj(scope)]);
export const set_global_option = (name, val) => set_option("global", name, val);

export function set_shortcut_mode(mode, lhs, rhs, opts_json = "{}") {
  const base = { noremap: true, silent: true };
  const opts = { ...base, ...parse(opts_json) };
  return ensure().call("nvim_set_keymap", [mode, lhs, rhs, opts]);
}
export function del_shortcut_mode(mode, lhs, _opts_json = "{}") {
  return ensure().call("nvim_del_keymap", [mode, lhs]);
}

// Cached channel id (if available)
export function get_channel_id() {
  return globalThis.__last_channel_id_cache ?? 0;
}

// Raw Lua executor (Gleam expects sync-looking function)
export function exec_lua_raw(code, args_json = "[]") {
  const args = parse(args_json, []);
  return ensure().execLua(code, args);
}

// Raw set_var (fire and forget)
export function set_var_raw(name, value) {
  ensure().call("nvim_set_var", [name, value]);
}

// Raw get_var (returns Result)
export function get_var_raw(name) {
  try {
    const v = ensure().call("nvim_get_var", [name]);
    return Ok(v ?? null);
  } catch (err) {
    return Error_(normalizeErr(err));
  }
}
