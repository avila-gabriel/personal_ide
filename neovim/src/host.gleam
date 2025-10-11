import gleam/dynamic.{type Dynamic}

@external(javascript, "./host.mjs", "_init")
pub fn init_host(plugin: String) -> Nil

@external(javascript, "./host.mjs", "command")
pub fn command(text: String) -> Nil

@external(javascript, "./host.mjs", "execLua")
pub fn exec_lua(lua: String, args: List(String)) -> Dynamic

@external(javascript, "./host.mjs", "callFunction")
pub fn call_function(name: String, args: List(String)) -> Dynamic

@external(javascript, "./host.mjs", "notify")
pub fn notify(name: String, args: List(String)) -> Dynamic

@external(javascript, "./host.mjs", "setVar")
pub fn set_var(name: String, value: String) -> Nil

@external(javascript, "./host.mjs", "getVar")
pub fn get_var(name: String) -> Dynamic

@external(javascript, "./host.mjs", "feedKeys")
pub fn feed_keys(keys: String, mode: String, escape_csi: Bool) -> Nil

@external(javascript, "./host.mjs", "redraw")
pub fn redraw(force: Bool) -> Nil

@external(javascript, "./host.mjs", "getCurrentBuffer")
pub fn current_buffer() -> Dynamic

@external(javascript, "./host.mjs", "getCurrentWindow")
pub fn current_window() -> Dynamic

@external(javascript, "./host.mjs", "getCurrentTabpage")
pub fn current_tabpage() -> Dynamic

@external(javascript, "./host.mjs", "setOption")
pub fn set_option(scope: String, name: String, value: String) -> Nil

@external(javascript, "./host.mjs", "getOption")
pub fn get_option(scope: String, name: String) -> Dynamic

@external(javascript, "./host.mjs", "setGlobalOption")
pub fn set_global_option(name: String, value: String) -> Nil

@external(javascript, "./host.mjs", "setKeymap")
pub fn set_keymap(
  mode: String,
  lhs: String,
  rhs: String,
  opts_json: String,
) -> Nil

@external(javascript, "./host.mjs", "setKeymapDefault")
pub fn set_keymap_default(mode: String, lhs: String, rhs: String) -> Nil

@external(javascript, "./host.mjs", "setKeymapWithDesc")
pub fn set_keymap_with_desc(
  mode: String,
  lhs: String,
  rhs: String,
  desc: String,
) -> Nil

@external(javascript, "./host.mjs", "deleteKeymap")
pub fn delete_keymap(mode: String, lhs: String, opts_json: String) -> Nil

@external(javascript, "./host.mjs", "createAutocmd")
pub fn create_autocmd(event: String, opts_json: String) -> Nil

@external(javascript, "./host.mjs", "clearAutocmds")
pub fn clear_autocmds(opts_json: String) -> Nil

@external(javascript, "./host.mjs", "createAugroup")
pub fn create_augroup(name: String, opts_json: String) -> Nil

@external(javascript, "./host.mjs", "registerCommand")
pub fn register_command(
  name: String,
  handler: fn(List(String)) -> Nil,
  opts_json: String,
) -> Nil

@external(javascript, "./host.mjs", "createUserCommand")
pub fn create_user_command(
  name: String,
  definition: String,
  opts_json: String,
) -> Nil

@external(javascript, "./host.mjs", "outWrite")
pub fn out_write(text: String) -> Nil
