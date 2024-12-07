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
    __github_select_codespace = builtins.readFile ./functions/__github_select_codespace.fish;
    github_codespace_open = builtins.readFile ./functions/github_codespace_open.fish;
    github_codespace_ssh = builtins.readFile ./functions/github_codespace_ssh.fish;
    github_open_pr = builtins.readFile ./functions/github_open_pr.fish;
    github_switch_pr = builtins.readFile ./functions/github_switch_pr.fish;
    run_gh = builtins.readFile ./functions/run_gh.fish;
  };

  programs.fish.shellInit = ''
    bind \cxhp github_switch_pr
    bind \cxho github_open_pr
    bind \cxco github_codespace_open
    bind \cxcs github_codespace_ssh
  '';
}
