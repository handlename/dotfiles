{
  ...
}:

{
  # The dispatcher installed into each repository's post-checkout hook runs this
  # path literally, so it must stay in sync with `install.sh`.
  xdg.dataFile."worktree-setup/setup-worktree.sh" = {
    source = ./setup-worktree.sh;
    executable = true;
  };

  home.file."bin/worktree-setup-install" = {
    source = ./install.sh;
    executable = true;
  };
}
