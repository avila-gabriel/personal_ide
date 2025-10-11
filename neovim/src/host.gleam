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
