{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish.functions = {
    git_cd = builtins.readFile ./functions/git_cd.fish;
    git_generate_ignore = builtins.readFile ./functions/git_generate_ignore.fish;
    git_goto_repository = builtins.readFile ./functions/git_goto_repository.fish;
    git_help = builtins.readFile ./functions/git_help.fish;
    git_switch_branch = builtins.readFile ./functions/git_switch_branch.fish;
  };

  programs.fish.shellAbbrs = {
    g = "git";
    lg = "lazygit";
  };

  programs.fish.shellInit = ''
    bind \cxgb git_switch_branch
    bind \cxgc git_cd
    bind \cxgg git_goto_repository
    bind \cxgh git_help
  '';
}
