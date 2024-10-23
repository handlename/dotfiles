{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish.shellInit = ''
    if test (uname) = Darwin
        set -x SSH_AUTH_SOCK (/bin/launchctl getenv SSH_AUTH_SOCK)
    end
  '';
}
