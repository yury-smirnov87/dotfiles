-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Hold the configuration in a variable
local config = {}

-- In newer versions of wezterm, use the config_builder if available
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font 'JetBrains Mono Nerd Font'
config.font_size = 11.0

-- Window size settings
config.initial_cols = 210
config.initial_rows = 30

-- UI Enhancements
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = 'Gruvbox Material (Gogh)' -- A classic Debian-friendly look

-- Optional: Subtle Window Padding for a cleaner look
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Performance & Integration for Debian Trixie
config.enable_wayland = true
config.front_end = "WebGpu"

-- Return the configuration to wezterm
return config
