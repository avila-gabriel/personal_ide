### `AGENTS.md`

```md
# AGENTS GUIDE
1. Use cmd extras: `rga` for ripgrep and `ctx` for quick context dumps (generated `code_context.md` at `.`).
2. Run full test suite using `gleam test` at `neovim/`.
3. JS FFI sticks to semicolons, single quotes, and async/await error guards as in `rplugin/node/bridge.js`.
4. Order Gleam imports with stdlib (`gleam/*`) before local modules; drop unused ones.
5. Prefer pipelines for collection transforms and keep functions small and pure.
6. Handle errors via Gleam `Result` or descriptive JS `Error`; never swallow exceptions silently.
7. Guard FFI access with `ensure()` (see `host_ffi.mjs`) before calling nvim APIs.
8. Node bridge loads Gleam output from `neovim/build/dev/javascript`; rebuild before trying in Neovim (´gleam build´ at neovim/).
9. No comments in code, unless its a unobvious decision that must be explicitly pointed.
10. No Cursor or Copilot rules detected; rely solely on this guide.
11. Keep this playbook current when tooling or workflows change.


```

### `init.lua`

```lua
vim.o.paste = false
vim.o.backspace = "indent,eol,start"
vim.o.mouse = "a"
vim.o.termguicolors = true
vim.o.number = true
vim.cmd("syntax on")
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.g.clipboard = {
	name = "clip-provider",
	copy = {
		["+"] = "clip.exe",
		["*"] = "clip.exe",
	},
}

vim.g.mapleader = " "

vim.g.node_host_prog = [[C:\Program Files\nodejs\node_modules\neovim\bin\cli.js]]

vim.api.nvim_create_user_command("ReloadRemotePlugins", "UpdateRemotePlugins", {})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
      },
      formatters = {
        biome = {
          command = "biome",
          args = { "format", "--stdin-file-path", "$FILENAME" },
          stdin = true,
        },
      },
    },
  },
}, {
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})
	
```

### `lazy-lock.json`

```json
{
  "conform.nvim": { "branch": "master", "commit": "fbcb4fa7f34bfea9be702ffff481a8e336ebf6ed" },
  "lazy.nvim": { "branch": "main", "commit": "6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a" }
}

```

### `package.json`

```json
{
  "name": "nvim",
  "version": "1.0.0",
  "dependencies": {
    "neovim": "^5.4.0"
  }
}

```

### `neovim\gleam.toml`

```toml
name = "neovim"
version = "1.0.0"
target = "javascript"

[dependencies]
gleam_stdlib = ">= 0.44.0 and < 2.0.0"

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"

```

### `neovim\src\global_options.gleam`

```gleam
import host

pub fn apply() {
  host.set_global_option("clipboard", "unnamedplus")
}

```

### `neovim\src\host.gleam`

```gleam
@external(javascript, "./host_ffi.mjs", "command")
pub fn command(text: String) -> Nil

@external(javascript, "./host_ffi.mjs", "out_write")
pub fn out_write(text: String) -> Nil

@external(javascript, "./host_ffi.mjs", "set_global_option")
pub fn set_global_option(name: String, value: String) -> Nil

@external(javascript, "./host_ffi.mjs", "set_shortcut_mode")
pub fn set_shortcut_mode(
  mode: String,
  lhs: String,
  rhs: String,
  opts_json: String,
) -> Nil

@external(javascript, "./host_ffi.mjs", "del_shortcut_mode")
pub fn del_shortcut_mode(mode: String, lhs: String, opts_json: String) -> Nil

@external(javascript, "./host_ffi.mjs", "execute_lua")
pub fn execute_lua(code: String) -> Result(String, String)

```

### `neovim\src\host_ffi.mjs`

```mjs
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

```

### `neovim\src\main.gleam`

```gleam
import global_options
import lazy/conform
import shortcuts

pub fn main() {
  global_options.apply()
  shortcuts.apply()
  conform.apply()
}

```

### `neovim\src\shortcuts.gleam`

```gleam
import gleam/list
import host

pub fn apply() -> Nil {
  // --- Select all ---
  // <leader>a in normal + visual
  ["n", "v"]
  |> list.each(fn(mode) {
    host.set_shortcut_mode(
      mode,
      "<leader>a",
      "ggVG",
      "{\"desc\":\"Select all\"}",
    )
  })

  // Ctrl+A (normal only)
  host.set_shortcut_mode("n", "<C-a>", "ggVG", "{\"desc\":\"Select all\"}")

  // --- Clipboard ---
  // Ctrl+C (visual only) — copy to + register
  host.set_shortcut_mode(
    "v",
    "<C-c>",
    "\"+y",
    "{\"desc\":\"Copy to clipboard\"}",
  )

  // --- Remap i/j/k/l in n,v,o modes ---
  let nav_modes = ["n", "v", "o"]
  nav_modes
  |> list.each(fn(m) {
    host.set_shortcut_mode(m, "i", "k", "{\"desc\":\"Up\"}")
    host.set_shortcut_mode(m, "j", "h", "{\"desc\":\"Left\"}")
    host.set_shortcut_mode(m, "k", "j", "{\"desc\":\"Down\"}")
    host.set_shortcut_mode(m, "l", "l", "{\"desc\":\"Right\"}")
  })

  // --- Window navigation with Alt + {j,k,i,l} (normal only) ---
  host.set_shortcut_mode("n", "<A-j>", "<C-w>h", "{\"desc\":\"Win left\"}")
  host.set_shortcut_mode("n", "<A-k>", "<C-w>j", "{\"desc\":\"Win down\"}")
  host.set_shortcut_mode("n", "<A-i>", "<C-w>k", "{\"desc\":\"Win up\"}")
  host.set_shortcut_mode("n", "<A-l>", "<C-w>l", "{\"desc\":\"Win right\"}")

  // ';' enters insert (normal only)
  host.set_shortcut_mode("n", ";", "i", "{\"desc\":\"Enter insert\"}")

  Nil
}

```

### `neovim\src\lazy\conform.gleam`

```gleam
import host

pub fn apply() -> Nil {
  let lua_code =
    "
    local ok, _ = pcall(require, 'conform')
    if not ok then
      vim.notify('conform.nvim not found (skipping autocmd)', vim.log.levels.WARN)
      return
    end

    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = { '*.ts', '*.tsx', '*.js', '*.jsx', '*.json' },
      callback = function(args)
        require('conform').format({ bufnr = args.buf })
      end
    })
    "

  case host.execute_lua(lua_code) {
    Ok(_) -> Nil
    Error(err) -> host.out_write("Conform autocmd setup failed: " <> err)
  }
}

```

### `neovim\test\neovim_test.gleam`

```gleam


```

### `rplugin\node\bridge.js`

```js
const path = require('path');
const { pathToFileURL } = require('url');

module.exports = (plugin) => {
  const nvim = plugin.nvim;

  plugin.registerAutocmd('VimEnter', async () => {
    try {
      const hostUrl  = pathToFileURL(
        path.join(__dirname, '../../neovim/build/dev/javascript/neovim/host_ffi.mjs')
      ).href;
      const gleamUrl = pathToFileURL(
        path.join(__dirname, '../../neovim/build/dev/javascript/neovim/main.mjs')
      ).href;

      const host  = await import(hostUrl);
      host.init(plugin);

      const gleam = await import(gleamUrl);
      await gleam.main();

      await nvim.command('echo "[bridge] gleam main() ran"');
    } catch (err) {
      await nvim.command('echoerr "[bridge] ' + String(err).replace(/"/g, '\\"') + '"');
      console.error('[bridge]', err);
    }
  }, { pattern: '*', once: true, sync: true });
};

```
