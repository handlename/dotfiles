{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish.shellInit = ''
    if test -f $HOME/.config/op/plugins.sh
        source $HOME/.config/op/plugins.sh
    end
  '';
}
