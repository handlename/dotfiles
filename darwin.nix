{ ... }:
{
  nix = {
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  services.nix-daemon.enable = true;

  system = {
    defaults = {
      WindowManager.EnableTiledWindowMargins = false;

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        "com.apple.trackpad.scaling" = 3.0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        orientation = "left";
      };

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };

      trackpad = {
        Clicking = true;
      };
    };
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      # enable after almost all appliactions are installed by nix
      # cleanup = "zap";
    };

    casks = [
      "1password-cli"
      "alfred"
      "appcleaner"
      "arc"
      "bettertouchtool"
      "dash"
      "discord"
      "emacs"
      "font-monaspace-nerd-font"
      "google-japanese-ime"
      "karabiner-elements"
      "obsidian"
      "orbstack"
      "slack"
      "visual-studio-code"
    ];

    masApps = {
      kindle = 302584613;
      reeder = 6475002485;
      toggl-track = 1291898086;
    };
  };
}
