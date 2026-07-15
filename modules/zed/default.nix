{
  config,
  username,
  ...
}:

{
  programs.zed-editor = {
    enable = true;
    package = null;

    # To avoid full build
    # Zed will be installed via Homebrew cask
    package = null;

    extensions = import ./extensions.nix;
    userSettings = import ./settings.nix { inherit username; };
    userKeymaps = import ./keymap.nix;
  };

  home.file = {
    "${config.xdg.configHome}/zed/tasks.json".source = ./tasks.json;
  };
}
