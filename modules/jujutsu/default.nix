{
  ...
}:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "NAGATA Hiroaki";
        email = "nagata@handlena.me";
      };
      signing = {
        behavior = "own";
        backend = "ssh";
        backends.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTVcp7Sd0Z99l0sQ6wIvaS4sq7an3AnpZ3ZOxZfxwWT";
      };
      git = {
        "sign-on-push" = true;
      };
    };
  };

  programs.jjui.enable = true;
}
