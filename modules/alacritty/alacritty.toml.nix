{
  username,
}:

''
  terminal.shell = "/Users/${username}/.nix-profile/bin/fish"

  general.import = ["~/.config/alacritty/themes/solarized_osaka.toml"]

  [window]
  option_as_alt = "Both"

  [font]
  normal = { family = "Moralerspace Argon NF" }
  size = 13

  [hints]
  alphabet = "aoeuidhtns"

  [[hints.enabled]]
  # default. see `man 5 alacritty` > HINTS > enabled
  command = "open"
  hyperlinks = true
  post_processing = true
  persist = false
  mouse.enabled = true
  binding = { key = "U", mods = "Control|Shift" }
  regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\u0000-\u001F\u007F-\u009F<>\"\\s{-}\\^⟨⟩`]+"

  [[hints.enabled]]
  regex = "[^ ]+\\.(go|json|jsonnet|libsonnet|md|pl|rb|rs|sh|tf|toml|txt|ya?ml)(:\\d+)?(:\\d+)?"
  command = { program = "/opt/homebrew/bin/code", args = ["--goto"] }
  binding = { key = "C", mods = "Control|Shift" }
  mouse.enabled = true

  [[keyboard.bindings]]
  key = "T"
  mods = "Control|Shift"
  action = "ToggleViMode"

  [[keyboard.bindings]]
  key = "Q"
  mode = "Vi"
  action = "ToggleViMode"

  [[keyboard.bindings]]
  key = "Escape"
  mode = "Vi"
  action = "ToggleViMode"
''
