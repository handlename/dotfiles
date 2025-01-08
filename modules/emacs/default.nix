{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  vars = import ../../vars.nix;
  moduleHome = toString ./.;
in
{
  home.file = {
    ".emacs.d/init.el".text = builtins.readFile ./init.el;
  };
}
