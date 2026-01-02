{
  config,
  ...
}:

{
  programs.zed-editor = {
    enable = true;

    extensions = import ./extensions.nix;
    userSettings = import ./settings.nix;
    userKeymaps = import ./keymap.nix;
  };

  home.file = {
    "${config.xdg.configHome}/zed/tasks.json".source = ./tasks.json;
  };
}
