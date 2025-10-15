
local wezterm = require 'wezterm'
local mux = wezterm.mux

local config = {}

-- Start Nushell by default
config.default_prog = { "nu" }
config.alternate_buffer_wheel_scroll_speed = 0
config.disable_default_mouse_bindings = false


-- Disable Alt+Enter fullscreen toggle (free it for broot)
config.keys = {
  { key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
  -- Optional: keep a manual fullscreen toggle on F9
  { key = "F9", mods = "", action = wezterm.action.ToggleFullScreen },
}

-- Maximize window on startup
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Misc
config.max_fps = 30
config.hide_tab_bar_if_only_one_tab = true

return config
