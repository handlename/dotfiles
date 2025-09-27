{
  config,
  ...
}:

{
  programs.zellij.enable = true;

  # place file because programs.zellij not supports kdl format
  home.file = {
    "${config.xdg.configHome}/zellij/config.kdl".source = ./config.kdl;
    "${config.xdg.configHome}/zellij/layouts/default.kdl".source = ./layouts/default.kdl;
  };
}
