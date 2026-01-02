{
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # disable cache generation to speed up switch.
  documentation.man.generateCaches = false;
}
