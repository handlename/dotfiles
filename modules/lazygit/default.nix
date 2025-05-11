{
  programs.lazygit = {
    enable = true;

    settings = {
      os = {
        open = "zed-preview {{filename}}";
      };
    };
  };
}
