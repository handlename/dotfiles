{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  vars = import ../../vars.nix;
  moduleHome = toString ./.;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = true;
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github.pub";
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
    };

    extraConfig = ''
      GSSAPIAuthentication = "no"
    '';

    includes = [
      "conf.d/*"
    ];
  };

  home.file = {
    "id_ed25519_github.pub" = {
      source = "${moduleHome}/certs/id_ed25519_github.pub";
      target = ".ssh/id_ed25519_github.pub";
    };
  };
}
