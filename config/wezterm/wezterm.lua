local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { '/opt/homebrew/bin/fish', '-l' }

config.font = wezterm.font 'Moralerspace Argon NF'
config.font_size = 13.0
config.color_scheme = 'Selenized Dark (Gogh)'

return config
