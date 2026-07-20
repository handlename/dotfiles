{
  ...
}:

{
  programs.helix = {
    enable = true;

    settings = {
      editor = {
        line-number = "relative";
        soft-wrap = {
          enable = true;
        };
      };
      keys.normal = {
        y = ["yank" ":clipboard-yank"];
      };
    };
  };
}
