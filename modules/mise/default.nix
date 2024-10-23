{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    globalConfig = {
      settings.experimental = true;
      env = {
        XDG_CACHE_HOME = "${config.xdg.cacheHome}";
        XDG_CONFIG_HOME = "${config.xdg.configHome}";
        XDG_DATA_HOME = "${config.xdg.dataHome}";
        XDG_STATE_HOME = "${config.xdg.stateHome}";

        ZELLIJ_LAYOUT_DIR = "${config.xdg.configHome}/zellij/layouts";
        ZELLIJ_LAYOUT_ROOT = "${config.home.homeDirectory}";
      };
      tools = {
        usage = "latest";
      };
    };
  };
}
