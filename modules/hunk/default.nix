{
  inputs,
  ...
}:

{
  imports = [
    inputs.hunk.homeManagerModules.default
  ];

  programs.hunk = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      theme = "auto";
      mode = "stack";
      line_numbers = true;
    };
  };
}
