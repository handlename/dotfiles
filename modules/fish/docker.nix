{
  ...
}:

{
  programs.fish.functions = {
    docker_image = builtins.readFile ./functions/docker_image.fish;
    docker_container = builtins.readFile ./functions/docker_image.fish;
  };

  programs.fish.shellInit = ''
    bind \cxdi docker_image
    bind \cxdc docker_container
  '';
}
