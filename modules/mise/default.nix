{
  config,
  ...
}:

let

in
{
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    globalConfig = {
      settings.experimental = true;
      env = {
        _.path = [
          "${config.home.homeDirectory}/bin"
        ];
        SHELL = "${config.home.homeDirectory}/.nix-profile/bin/fish";
        XDG_CACHE_HOME = "${config.xdg.cacheHome}";
        XDG_CONFIG_HOME = "${config.xdg.configHome}";
        XDG_DATA_HOME = "${config.xdg.dataHome}";
        XDG_STATE_HOME = "${config.xdg.stateHome}";

        ZELLIJ_LAYOUT_DIR = "${config.xdg.configHome}/zellij/layouts";
        ZELLIJ_LAYOUT_ROOT = "${config.home.homeDirectory}";
      };
      tools = {
        usage = "latest";
        go = "latest";
        node = "latest";
      };
    };
  };
}
