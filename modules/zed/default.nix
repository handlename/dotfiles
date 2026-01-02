{
  config,
  ...
}:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      # languages
      "docker-compose"
      "dockerfile"
      "fish"
      "html"
      "jsonnet"
      "kdl"
      "lua"
      "make"
      "nginx"
      "nix"
      "perl"
      "sql"
      "terraform"
      "toml"

      # themes
      "github-theme"

      # icon themes
      "material-icon-theme"

      # mcp servers
      "mcp-server-context7"
      "mcp-server-github"
      "serena-context-server"
    ];

    userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
    userKeymaps = builtins.fromJSON (builtins.readFile ./keymap.json);
  };

  home.file = {
    "${config.xdg.configHome}/zed/tasks.json".source = ./tasks.json;
  };
}
