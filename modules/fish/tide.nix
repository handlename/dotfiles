{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish.shellInit = ''
    set -g tide_git_truncation_length 64
  '';
}
