{ pkgs, ... }:
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
      NSGlobalDomain.AppleShowAllExtensions = true;

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };

      dock = {
        autohide = true;
        show-recents = false;
        orientation = "left";
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
      "docker"
      "discord"
      "font-monaspace-nerd-font"
      "google-japanese-ime"
      "karabiner-elements"
      "obsidian"
      "slack"
      "toggl-track"
      "visual-studio-code"
    ];

    masApps = {
      kindle = 302584613;
      reeder = 6475002485;
    };
  };
}
