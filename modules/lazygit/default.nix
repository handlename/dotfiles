{
  programs.lazygit = {
    enable = true;

    settings = {
      os = {
        open = "zed {{filename}}";
      };
      customCommands = [
        # https://github.com/jesseduffield/lazygit/wiki/Custom-Commands-Compendium#open-existing-github-pull-request-in-browser
        {
          key = "G";
          command = "gh pr view -w {{.SelectedLocalBranch.Name}}";
          context = "localBranches";
          description = "Open Github PR in browser";
        }
        {
          key = "G";
          command = "gh pr view -w";
          context = "commits";
          description = "Open Github PR in browser";
        }
      ];
    };
  };
}
