{
  config,
  username,
  ...
}:

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
