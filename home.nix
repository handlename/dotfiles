{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ./vars.nix;
in
{

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nagata-hiroaki";
  home.homeDirectory = "/Users/nagata-hiroaki";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    pkgs.awscli
    pkgs.docker-compose
    pkgs.fzf
    pkgs.gh
    pkgs.ghq
    pkgs.git
    pkgs.git-secrets
    pkgs.glib
    pkgs.gnupg
    pkgs.graphviz
    pkgs.imagemagick
    pkgs.jq
    pkgs.jsonnet
    pkgs.keychain
    pkgs.mise
    pkgs.netcat
    pkgs.nixpkgs-fmt
    pkgs.openssl
    pkgs.pcre
    pkgs.pkg-config
    pkgs.readline
    pkgs.ripgrep
    pkgs.tig
    pkgs.tree
    pkgs.vim
    pkgs.watch
    pkgs.wget
    pkgs.zellij
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nagata-hiroaki/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  xdg.enable = true;

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    globalConfig = {
      settings.experimental = true;
      env = {
        XDG_CACHE_HOME = "${config.xdg.cacheHome}";
        XDG_CONFIG_HOME = "${config.xdg.configHome}";
        XDG_DATA_HOME = "${config.xdg.dataHome}";
        XDG_STATE_HOME = "${config.xdg.stateHome}";
      };
      tools = {
        usage = "latest";
      };
    };
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
  };

  home.activation = {
    symlinkConfiglations = lib.mkAfter ''
      run mkdir -p ${config.xdg.configHome}
      run ln -sf ${vars.homeManagerHome}/config/alacritty ${config.xdg.configHome}/
      run ln -sf ${vars.homeManagerHome}/config/git ${config.xdg.configHome}/
      run ln -sf ${vars.homeManagerHome}/config/zellij ${config.xdg.configHome}/
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
