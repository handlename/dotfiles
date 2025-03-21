{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish.shellInit = ''
    set -U FZF_LEGACY_KEYBINDINGS 0
    set -x FZF_DEFAULT_OPTS '--layout=reverse --height 40%'

    bind --erase \cf __fzf_find_file
    bind --erase --mode insert \cf __fzf_find_file
  '';
}
