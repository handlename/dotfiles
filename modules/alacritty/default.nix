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
    "${config.xdg.configHome}/alacritty/alacritty.toml" = {
      text = builtins.readFile ./alacritty.toml;
    };

    "${config.xdg.configHome}/alacritty/themes" = {
      recursive = true;
      source = ./themes;
    };
  };
}
