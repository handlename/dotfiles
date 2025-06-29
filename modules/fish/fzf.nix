{
  ...
}:

{
  programs.fish.shellInit = ''
    set -U FZF_LEGACY_KEYBINDINGS 0
    set -x FZF_DEFAULT_OPTS '--layout=reverse --height 40%'
  '';
}
