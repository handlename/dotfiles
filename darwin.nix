{ pkgs, ... }:
{
  nix = {
    optimise.automatic = true;
    settings = {
      experimental-feature = "nix-command flakes";
    };
  };

  service.nix-daemon.enable = true;

  system = {
    defaults = {
      NSGlobalDomain.AppleShowAllExtensions = true;
    };
  };
}
