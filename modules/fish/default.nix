{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish = {
    enable = true;
    plugins = [
      # {
      #   name = "bd";
      #   src = pkgs.fishPlugins.fish-bd;
      # }
      {
        name = "tide";
        src = pkgs.fishPlugins.tide;
      }
    ];
  };

  programs.fish.shellAliases = {
    # ls
    l = "less";
    ls = "ls -G";
    la = "ls -aG";
    ll = "ls -lhG";
    lla = "ls -lahG";

    # rsync
    rsync = "rsync -P";
  };

  imports = [
    ./1password.nix
    ./aws.nix # bind prefix: \cxa
    ./docker.nix # bind prefix: \cxd
    ./fzf.nix
    ./git.nix # bind prefix: \cxg
    ./github.nix # bind prefix: \cxh
    ./ssh.nix
    ./tide.nix
    ./zellij.nix
  ];
}
