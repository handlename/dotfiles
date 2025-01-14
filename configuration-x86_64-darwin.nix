{ ... }:
{
  system.stateVersion = 1;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-darwin";
}
