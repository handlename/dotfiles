{
  programs.oh-my-posh = {
    enable = false;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config.json);
  };
}
