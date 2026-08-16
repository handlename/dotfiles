{
  config,
  lib,
  pkgs,
  ...
}:

let
  karabinerLib = import ./lib.nix { inherit lib; };
  inherit (karabinerLib) toSimpleModifications mkKeyboard keyboards;

  dvorakSimpleModifications = toSimpleModifications (import ./simple-modifications/dvorak.nix);
  fnFunctionKeys = toSimpleModifications (import ./simple-modifications/fn-function-keys.nix);

  dvorakDevices = with keyboards; [
    (mkKeyboard { identifiers = customKeyboard; simple_modifications = [ ]; })
    (mkKeyboard { identifiers = appleInternal1; simple_modifications = dvorakSimpleModifications; })
    (mkKeyboard { identifiers = appleInternal2; simple_modifications = dvorakSimpleModifications; })
    (mkKeyboard { identifiers = magicKeyboard1; simple_modifications = dvorakSimpleModifications; })
    (mkKeyboard { identifiers = magicKeyboard2; simple_modifications = dvorakSimpleModifications; })
  ];

  commonProfileParameters = {
    delay_milliseconds_before_open_device = 1000;
  };

  commonVirtualHidKeyboard = {
    caps_lock_delay_milliseconds = 0;
    country_code = 0;
    indicate_sticky_modifier_keys_state = true;
    keyboard_type = "ansi";
    mouse_key_xy_scale = 100;
    standalone_keys_delay_milliseconds = 200;
  };

  commonComplexModificationsParameters = {
    "basic.simultaneous_threshold_milliseconds" = 50;
    "basic.to_delayed_action_delay_milliseconds" = 500;
    "basic.to_if_alone_timeout_milliseconds" = 1000;
    "basic.to_if_held_down_threshold_milliseconds" = 500;
    "mouse_motion_to_scroll.speed" = 100;
  };

  karabinerConfig = {
    global = {
      check_for_updates_on_startup = true;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
    };
    profiles = [
      {
        name = "dvorak+";
        selected = true;
        parameters = commonProfileParameters;
        virtual_hid_keyboard = commonVirtualHidKeyboard;
        complex_modifications = {
          parameters = commonComplexModificationsParameters;
          rules = [
            (import ./complex-modifications/exchange-numbers-and-symbols.nix)
            (import ./complex-modifications/spacebar-to-left-shift.nix)
            (import ./complex-modifications/command-to-eisuu-kana.nix)
          ];
        };
        fn_function_keys = fnFunctionKeys;
        devices = dvorakDevices;
        one_to_many_mappings = { };
        simple_modifications = [ ];
      }
      {
        name = "vanilla";
        selected = false;
        parameters = commonProfileParameters;
        virtual_hid_keyboard = commonVirtualHidKeyboard;
        complex_modifications = {
          parameters = commonComplexModificationsParameters;
          rules = [ ];
        };
        fn_function_keys = fnFunctionKeys;
        devices = [ ];
        one_to_many_mappings = { };
        simple_modifications = [ ];
        standalone_keys = { };
      }
    ];
  };
in
{
  xdg.configFile."karabiner/karabiner.json" = {
    text = builtins.toJSON karabinerConfig;
    force = true;
  };
}
