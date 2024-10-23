{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
  moduleHome = toString ./.;
in
{
  home.activation = {
    # symlink config because programs.zellij not supports kdl format
    zellijSymlinkConfig = lib.mkAfter ''
      run mkdir -p ${config.xdg.configHome}/zellij
      run ln -sf ${moduleHome}/config.kdl ${config.xdg.configHome}/zellij/config.kdl
    '';
  };
}
