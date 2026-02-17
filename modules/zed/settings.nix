{
  # appearance

  active_pane_modifiers = {
    border_size = 1.0;
    inactive_opacity = 0.5;
  };
  buffer_font_family = "MonaspiceAr Nerd Font Mono";
  buffer_font_size = 12;
  colorize_brackets = true;
  "experimental.theme_overrides" = {
    "terminal.background" = "#16160e";
  };
  icon_theme = "Material Icon Theme";
  tab_bar = {
    show = false;
  };
  theme = {
    dark = "GitHub Dark Dimmed";
    light = "GitHub Light";
    mode = "dark";
  };
  ui_font_size = 16;
  use_system_window_tabs = true; # for open projects in single window

  # editor

  autosave = {
    after_delay = {
      milliseconds = 1000;
    };
  };
  diagnostics = {
    inline = {
      enabled = true;
    };
  };
  file_scan_exclusions = [
    "vendor/*"
    "**/.git"
    "**/.svn"
    "**/.hg"
    "**/.jj"
    "**/CVS"
    "**/.DS_Store"
    "**/Thumbs.db"
    "**/.classpath"
    "**/.settings"
  ];
  file_types = {
    Ruby = [ "iam" ];
  };
  inlay_hints = {
    enabled = true;
    show_other_hints = true;
    show_parameter_hints = true;
    show_type_hints = true;
    toggle_on_modifiers_press = {
      control = true;
      shift = true;
    };
  };
  relative_line_numbers = "enabled";
  vim_mode = true;
  vim = {
    use_smartcase_find = true;
  };
  which_key = {
    enabled = true;
  };

  # terminal

  terminal = {
    shell = {
      program = "/Users/handlename/.nix-profile/bin/fish";
    };
    font_family = "Moralerspace Argon NF";
    font_size = 12;
    dock = "left";
    default_width = 1000;
  };

  # ai

  agent = {
    always_allow_tool_actions = true;
    default_model = {
      model = "claude-sonnet-4.5";
      provider = "copilot_chat";
    };
    default_profile = "ask";
    inline_assistant_model = {
      model = "claude-sonnet-4.5";
      provider = "copilot_chat";
    };
  };
  agent_servers = {
    claude = {
      default_mode = "bypassPermissions";
    };
  };
  collaboration_panel = {
    default_width = 1000;
  };
  edit_predictions = {
    mode = "eager";
  };
  features = {
    edit_prediction_provider = "zed";
  };

  # languages

  languages = {
    Go = {
      format_on_save = "on";
      formatter = {
        external = {
          arguments = [ ];
          command = "goimports";
        };
      };
    };
    HTML = {
      format_on_save = "off";
    };
    Nix = {
      language_servers = [
        "nixd"
        "!nil"
      ];
    };
    Perl = {
      enable_language_server = false;
    };
    Ruby = {
      enable_language_server = false;
    };
    YAML = {
      tab_size = 2;
    };
  };

  # extensions

  auto_install_extensions = {
    dockerfile = true;
    fish = true;
    github-theme = true;
    html = true;
    jsonnet = true;
    kdl = true;
    make = true;
    material-icon-theme = true;
    nix = true;
    sql = true;
    terraform = true;
    toml = true;
  };

  # others

  telemetry = {
    diagnostics = false;
    metrics = false;
  };
}
