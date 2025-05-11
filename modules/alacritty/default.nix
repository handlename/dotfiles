{
  config,
  lib,
  pkgs,
  username,
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
      text = import ./alacritty.toml.nix { inherit username; };
    };

    "${config.xdg.configHome}/alacritty/themes" = {
      recursive = true;
      source = ./themes;
    };
  };
}
