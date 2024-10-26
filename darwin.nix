{ pkgs, ... }:
{
  nix = {
    optimise.automatic = true;
    settings = {
      experimental-feature = "nix-command flakes";
    };
  };

  services.nix-daemon.enable = true;

  system = {
    defaults = {
      NSGlobalDomain.AppleShowAllExtensions = true;
    };
  };
}
