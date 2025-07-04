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
    activationScripts.extraActivation.text = ''
      softwareupdate --install-rosetta --agree-to-license
    '';

    defaults = {
      # To fill gaps between windows.
      # Use BetterTouchTool to manage window tiling instead.
      WindowManager.EnableTiledWindowMargins = false;

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15; # shortest
        KeyRepeat = 2; # fastest
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
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

      hitoolbox = {
        AppleFnUsageType = "Do Nothing";
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
      "1password"
      "1password-cli"
      "alacritty"
      "alfred"
      "appcleaner"
      "arc"
      "bettertouchtool"
      "dash"
      "discord"
      "emacs"
      "elecom-mouse-util"
      "font-monaspace-nerd-font"
      "font-moralerspace-nf"
      "google-chrome"
      "google-japanese-ime"
      "homerow"
      "jordanbaird-ice"
      "karabiner-elements"
      "obsidian"
      "slack"
      "session-manager-plugin"
      "visual-studio-code"
      "zed"
    ];

    masApps = {
      display-maid = 450063525;
      kindle = 302584613;
      reeder = 6475002485;
      snippety = 1530751461;
      toggl-track = 1291898086;
    };
  };
}
