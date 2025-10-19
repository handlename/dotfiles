{
  programs.oh-my-posh = {
    enable = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config.json);
  };
}
