{
  config,
  ...
}:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      # languages
      "dockerfile"
      "fish"
      "html"
      "make"
      "nix"
      "sql"
      "terraform"
      "toml"

      # themes
      "github-theme"
    ];

    userSettings = { };
    userKeymaps = [ ];
  };

  home.file = {
    "${config.xdg.configHome}/zed/tasks.json".source = ./tasks.json;
  };
}
