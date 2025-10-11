{
  ...
}:

{
  programs.fish.functions = {
    zellij_run_with_layout = builtins.readFile ./functions/zellij_run_with_layout.fish;
    zellij_run_with_default_layout = builtins.readFile ./functions/zellij_run_with_default_layout.fish;
  };

  programs.fish.shellInit = ''
    bind \cxzr zellij_run_with_layout
  '';
}
