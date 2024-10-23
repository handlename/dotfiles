{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.fish.shellAbbrs = {
    tf = "terraform";
  };
}
