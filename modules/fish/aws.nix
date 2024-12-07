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
    aws_help = builtins.readFile ./functions/aws_help.fish;
    __init_aws_help = builtins.readFile ./functions/__init_aws_help.fish;
  };

  programs.fish.shellAbbrs = {
    aw = "aswrap";
    ap = "AWS_PROFILE=";
  };
}
