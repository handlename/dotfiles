{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "bd";
        src = pkgs.fetchFromGitHub
          {
            owner = "0rax";
            repo = "fish-bd";
            rev = "v1.3.3";
            sha256 = "GeWjoakXa0t2TsMC/wpLEmsSVGhHFhBVK3v9eyQdzv0=";
          };
      }
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "v5";
          sha256 = "cCI1FDpvajt1vVPUd/WvsjX/6BJm6X1yFPjqohmo1rI=";
        };
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
