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
    if test (uname) = Darwin
        set -x SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    end
  '';
}
