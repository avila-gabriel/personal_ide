let _nvim = null;

const Ok = (v) => ({ type: "Ok", 0: v });
const Error_ = (e) => ({ type: "Error", 0: e });

export function parse(v, d = {}) {
  if (v == null) return d;
  if (typeof v === "string") {
    try {
      return JSON.parse(v);
    } catch {
      return d;
    }
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
}

export const command = (t) => ensure().command(t);
export const call_function = (n, a = []) => ensure().call(n, a);
export const out_write = (t) => ensure().outWrite(String(t) + "\n");

export function scope_obj(s) {
  switch (s) {
    case "global":
      return { scope: "global" };
    case "window":
      return { scope: "local", win: 0 };
    case "buffer":
      return { scope: "local", buf: 0 };
    default:
      throw new Error("bad scope");
  }
}

export const set_option = (scope, name, val) =>
  ensure().call("nvim_set_option_value", [name, val, scope_obj(scope)]);
export const get_option = (scope, name) =>
  ensure().call("nvim_get_option_value", [name, scope_obj(scope)]);
export const set_global_option = (name, val) =>
  set_option("global", name, val);

export function set_shortcut_mode(mode, lhs, rhs, opts_json = "{}") {
  const base = { noremap: true, silent: true };
  const opts = { ...base, ...parse(opts_json) };
  return ensure().call("nvim_set_keymap", [mode, lhs, rhs, opts]);
}

export function del_shortcut_mode(mode, lhs, _opts_json = "{}") {
  return ensure().call("nvim_del_keymap", [mode, lhs]);
}

export function execute_lua(code) {
  try {
    const result = ensure().execLua(code, []);
    return Ok(String(result ?? ""));
  } catch (err) {
    return Error_(String(err?.message ?? err));
  }
}
