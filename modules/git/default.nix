{ config, lib, pkgs, ... }:

with lib;

let
  vars = import ../../vars.nix;
in
{
  programs.git = {
    enable = true;

    userName = "NAGATA Hiroaki";
    userEmail = "nagata@handlena.me";

    aliases = {
      # add
      a = "add";
      aa = "add -A :/";
      au = "add -u :/";

      # commit
      amend = "commit --amend";
      cm = "commit -m";

      # checkout
      co = "checkout";

      # diff
      d = "diff";
      dc = "diff --cached";

      # log
      l = "log";
      lo = "log --oneline";
      ls = "log --stat";

      patch = "diff --no-prefix";
      pl = ''!sh -c 'git pull \"origin\" \"$(git rev-parse --symbolic-full-name HEAD)\"' -'';
      pr = "pull-request";

      # stash
      sl = "stash list";
      sp = "stash pop";
      ss = "stash save";

      # status
      st = "status";

      # shorthand
      clear = "!sh -c 'git reset HEAD && git checkout :/ && git clean -df'";
      find = "!git ls-files | grep -i";
      sync = "fetch --prune origin";
      update = ''!sh -c 'git pull origin \"$(git rev-parse --symbolic-full-name HEAD)\"' -'';
    };

    extraConfig = {
      core = {
        editor = "vim";
        ignorecase = "false";
        precomposeunicode = "true";
        quotepath = "false";
      };

      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
      };

      merge = {
        ff = "true";
      };

      pull = {
        rebase = "true";
      };

      push = {
        default = "current";
      };

      ghq = {
        root = "/Users/nagata-hiroaki/src";
      };

      secrets = {
        providers = "git secrets --aws-provider";

        patterns = [
          "(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}"
          "(\"|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)(\"|')?\\s*(:|=>|=)\\s*(\"|')?[A-Za-z0-9/\\+=]{40}(\"|')?"
          "(\"|')?(AWS|aws|Aws)?_?(ACCOUNT|account|Account)_?(ID|id|Id)?(\"|')?\\s*(:|=>|=)\\s*(\"|')?[0-9]{4}\\-?[0-9]{4}\\-?[0-9]{4}(\"|')?"
          "-----BEGIN .*PRIVATE KEY-----"
          "xox[bp]-[0-9]+-[a-zA-Z0-9]+"
        ];

        allowed = [
          "AKIAIOSFODNN7EXAMPLE"
          "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
          "GOPRIVATE"
        ];
      };

      init = {
        templateDir = "~/.git-templates/git-secrets";
        defaultBranch = "main";
      };
    };

    includes =
      if pkgs.stdenv.isDarwin then
        [
          {
            contents = {
              user = {
                signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB07qurqFbgVnhub71swh//KERuPJYsbttLY+v5v+G98";
              };
              gpg = {
                format = "ssh";
              };
              gpg."ssh" = {
                program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
              };
              commit = {
                gpgsign = "true";
              };
            };
          }
        ]
      else
        [ ];

    diff-highlight.enable = true;
  };
}