{
  ...
}:

{
  programs.fish.functions = {
    zed_open_repository = builtins.readFile ./functions/zed_open_repository.fish;
  };

  programs.fish.shellAbbrs = {
    z = "zed";
  };

  programs.fish.shellInit = ''
    bind \cxzo zed_open_repository
  '';
}
