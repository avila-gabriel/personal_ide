import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list

pub type Scope {
  Global
  Window
  Buffer
}

pub type KeymapOptions {
  KeymapOptions(
    noremap: Bool,
    silent: Bool,
    expr: Bool,
    nowait: Bool,
    script: Bool,
    unique: Bool,
    desc: String,
  )
}

pub type ApiInfo {
  ApiInfo(channel_id: Int, metadata: Dynamic)
}

pub type NvimValue {
  NvimNil
  NvimBool(Bool)
  NvimInt(Int)
  NvimFloat(Float)
  NvimString(String)
  NvimList(List(NvimValue))
  NvimDict(List(#(String, NvimValue)))
}

pub type Notification {
  Notification(method: String, args: List(NvimValue))
}

@external(javascript, "./host_ffi.mjs", "command")
fn command(text: String) -> Nil

@external(javascript, "./host_ffi.mjs", "out_write")
fn out_write(text: String) -> Nil

@external(javascript, "./host_ffi.mjs", "set_global_option")
pub fn set_global_option(name: String, value: String) -> Nil

@external(javascript, "./host_ffi.mjs", "set_shortcut_mode")
fn set_shortcut_mode(
  mode: String,
  lhs: String,
  rhs: String,
  opts_json: String,
) -> Nil

@external(javascript, "./host_ffi.mjs", "del_shortcut_mode")
fn del_shortcut_mode(mode: String, lhs: String, opts_json: String) -> Nil

@external(javascript, "./host_ffi.mjs", "get_channel_id")
pub fn get_channel_id() -> Int

@external(javascript, "./host_ffi.mjs", "exec_lua")
fn exec_lua_raw(code: String, args_json: String) -> Dynamic

@external(javascript, "./host_ffi.mjs", "on_notification")
fn on_notification(cb: String) -> Nil

@external(javascript, "./host_ffi.mjs", "set_var")
fn set_var_raw(name: String, value: Dynamic) -> Nil

@external(javascript, "./host_ffi.mjs", "get_var")
fn get_var_raw(name: String) -> Result(Dynamic, String)

pub fn decode_keymap_options() -> decode.Decoder(KeymapOptions) {
  use noremap <- decode.field("noremap", decode.bool)
  use silent <- decode.field("silent", decode.bool)
  use expr <- decode.optional_field("expr", False, decode.bool)
  use nowait <- decode.optional_field("nowait", False, decode.bool)
  use script <- decode.optional_field("script", False, decode.bool)
  use unique <- decode.optional_field("unique", False, decode.bool)
  use desc <- decode.optional_field("desc", "", decode.string)
  decode.success(KeymapOptions(
    noremap: noremap,
    silent: silent,
    expr: expr,
    nowait: nowait,
    script: script,
    unique: unique,
    desc: desc,
  ))
}

pub fn decode_nvim_value() -> decode.Decoder(NvimValue) {
  decode.one_of(decode.success(NvimNil), [
    decode.bool |> decode.map(NvimBool),
    decode.int |> decode.map(NvimInt),
    decode.float |> decode.map(NvimFloat),
    decode.string |> decode.map(NvimString),
    decode.list(decode_nvim_value()) |> decode.map(NvimList),
    decode.dict(decode.string, decode_nvim_value())
      |> decode.map(dict.to_list)
      |> decode.map(NvimDict),
  ])
}

fn result_envelope(
  inner: decode.Decoder(a),
) -> decode.Decoder(Result(a, String)) {
  use tag <- decode.field("type", decode.string)
  case tag {
    "Ok" -> {
      use v <- decode.field("value", inner)
      decode.success(Ok(v))
    }
    "Error" -> {
      use e <- decode.field("value", decode.string)
      decode.success(Error(e))
    }
    _ ->
      decode.failure(
        Error("not ok or error"),
        "unknown tag in host_ffi result helper",
      )
  }
}

pub fn execute_lua_typed(
  code: String,
  args: Json,
  decoder: decode.Decoder(a),
) -> Result(a, String) {
  let raw = exec_lua_raw(code, json.to_string(args))

  case decode.run(raw, result_envelope(decoder)) {
    Ok(Ok(value)) -> Ok(value)
    Ok(Error(err)) -> Error(err)
    Error(_) -> Error("Failed to decode lua envelope")
  }
}

pub fn decode_notification() -> decode.Decoder(Notification) {
  use method <- decode.then(decode.at([0], decode.string))
  use args <- decode.then(decode.at([1], decode.list(decode_nvim_value())))
  decode.success(Notification(method:, args:))
}

pub fn scope_to_string(scope: Scope) -> String {
  case scope {
    Global -> "global"
    Window -> "window"
    Buffer -> "buffer"
  }
}

pub fn execute_command(text: String) -> Nil {
  command(text)
}

pub fn write_output(text: String) -> Nil {
  out_write(text)
}

pub fn define_keymap(
  mode: String,
  lhs: String,
  rhs: String,
  options: KeymapOptions,
) -> Nil {
  set_shortcut_mode(mode, lhs, rhs, keymap_to_json(options))
}

fn keymap_to_json(keymap_options: KeymapOptions) -> String {
  json.object([
    #("noremap", json.bool(keymap_options.noremap)),
    #("silent", json.bool(keymap_options.silent)),
    #("expr", json.bool(keymap_options.expr)),
    #("nowait", json.bool(keymap_options.nowait)),
    #("script", json.bool(keymap_options.script)),
    #("unique", json.bool(keymap_options.unique)),
    #("desc", json.string(keymap_options.desc)),
  ])
  |> json.to_string
}

pub fn remove_keymap(mode: String, lhs: String) -> Nil {
  del_shortcut_mode(mode, lhs, "{}")
}

pub fn register_notification_callback(callback_name: String) -> Nil {
  on_notification(callback_name)
}

pub fn set_variable(name: String, value: NvimValue) -> Nil {
  set_var_raw(name, nvim_value_to_dynamic(value))
}

pub fn get_variable(name: String) -> Result(NvimValue, String) {
  case get_var_raw(name) {
    Ok(dynamic_result) ->
      case decode.run(dynamic_result, decode_nvim_value()) {
        Ok(value) -> Ok(value)
        Error(_) -> Error("Failed to decode variable")
      }
    Error(err) -> Error(err)
  }
}

pub fn get_variable_typed(
  name: String,
  decoder: decode.Decoder(a),
) -> Result(a, String) {
  case get_var_raw(name) {
    Ok(dynamic_result) ->
      case decode.run(dynamic_result, decoder) {
        Ok(value) -> Ok(value)
        Error(_) -> Error("Failed to decode variable")
      }
    Error(err) -> Error(err)
  }
}

pub fn set_variable_dynamic(name: String, value: Dynamic) -> Nil {
  set_var_raw(name, value)
}

pub fn get_variable_raw(name: String) -> Result(Dynamic, String) {
  get_var_raw(name)
}

pub fn set_variable_raw(name: String, value: Dynamic) -> Nil {
  set_var_raw(name, value)
}

pub fn define_keymap_json(
  mode: String,
  lhs: String,
  rhs: String,
  opts_json: String,
) -> Nil {
  set_shortcut_mode(mode, lhs, rhs, opts_json)
}

pub fn set_var(name: String, value: NvimValue) -> Nil {
  set_var_raw(name, nvim_value_to_dynamic(value))
}

pub fn get_var(name: String) -> Result(NvimValue, String) {
  case get_var_raw(name) {
    Ok(dynamic_result) ->
      case decode.run(dynamic_result, decode_nvim_value()) {
        Ok(value) -> Ok(value)
        Error(_) -> Error("Failed to decode variable")
      }
    Error(err) -> Error(err)
  }
}

pub fn set_shortcut(
  mode: String,
  lhs: String,
  rhs: String,
  options: KeymapOptions,
) -> Nil {
  set_shortcut_mode(mode, lhs, rhs, keymap_to_json(options))
}

fn nvim_value_to_dynamic(value: NvimValue) -> Dynamic {
  case value {
    NvimNil -> dynamic.nil()
    NvimBool(b) -> dynamic.bool(b)
    NvimInt(i) -> dynamic.int(i)
    NvimFloat(f) -> dynamic.float(f)
    NvimString(s) -> dynamic.string(s)
    NvimList(l) ->
      l
      |> list.map(nvim_value_to_dynamic)
      |> dynamic.list
    NvimDict(d) ->
      d
      |> list.map(fn(pair: #(String, NvimValue)) {
        #(dynamic.string(pair.0), nvim_value_to_dynamic(pair.1))
      })
      |> dynamic.properties
  }
}
