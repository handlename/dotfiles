{
  ...
}:

{
  xdg.configFile."hammerspoon/init.lua" = {
    source = ./init.lua;
    force = true;
  };
  xdg.configFile."hammerspoon/modules/app_switch.lua" = {
    source = ./modules/app_switch.lua;
    force = true;
  };
  xdg.configFile."hammerspoon/modules/window_control.lua" = {
    source = ./modules/window_control.lua;
    force = true;
  };
}
