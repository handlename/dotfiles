{
  config,
  lib,
  pkgs,
  ...
}:

let
  toSimpleModifications =
    mapping:
    lib.mapAttrsToList (from: to: {
      from = {
        key_code = from;
      };
      to = [
        {
          key_code = to;
        }
      ];
    }) mapping;

  dvorakMapping = {
    b = "x";
    c = "j";
    caps_lock = "left_control";
    close_bracket = "equal_sign";
    comma = "w";
    d = "e";
    e = "period";
    equal_sign = "close_bracket";
    f = "u";
    g = "i";
    h = "d";
    hyphen = "open_bracket";
    i = "k";
    j = "h";
    k = "t";
    l = "n";
    n = "b";
    o = "r";
    open_bracket = "slash";
    p = "l";
    period = "v";
    q = "quote";
    quote = "hyphen";
    r = "p";
    s = "o";
    semicolon = "s";
    slash = "z";
    t = "y";
    u = "g";
    v = "c";
    w = "comma";
    x = "q";
    y = "f";
    z = "semicolon";
  };

  dvorakSimpleModifications = toSimpleModifications dvorakMapping;

  fnFunctionKeys = [
    {
      from = {
        key_code = "f1";
      };
      to = [ { key_code = "display_brightness_decrement"; } ];
    }
    {
      from = {
        key_code = "f2";
      };
      to = [ { key_code = "display_brightness_increment"; } ];
    }
    {
      from = {
        key_code = "f3";
      };
      to = [ { key_code = "mission_control"; } ];
    }
    {
      from = {
        key_code = "f4";
      };
      to = [ { key_code = "launchpad"; } ];
    }
    {
      from = {
        key_code = "f5";
      };
      to = [ { key_code = "illumination_decrement"; } ];
    }
    {
      from = {
        key_code = "f6";
      };
      to = [ { key_code = "illumination_increment"; } ];
    }
    {
      from = {
        key_code = "f7";
      };
      to = [ { key_code = "rewind"; } ];
    }
    {
      from = {
        key_code = "f8";
      };
      to = [ { key_code = "play_or_pause"; } ];
    }
    {
      from = {
        key_code = "f9";
      };
      to = [ { key_code = "fastforward"; } ];
    }
    {
      from = {
        key_code = "f10";
      };
      to = [ { key_code = "mute"; } ];
    }
    {
      from = {
        key_code = "f11";
      };
      to = [ { key_code = "volume_decrement"; } ];
    }
    {
      from = {
        key_code = "f12";
      };
      to = [ { key_code = "volume_increment"; } ];
    }
  ];

  digits = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "0"
  ];

  exchangeNumbersAndSymbolsManipulators =
    (map (k: {
      from = {
        key_code = k;
        modifiers = {
          optional = [ "caps_lock" ];
        };
      };
      to = [
        {
          key_code = k;
          modifiers = [ "left_shift" ];
        }
      ];
      type = "basic";
    }) digits)
    ++ (map (k: {
      from = {
        key_code = k;
        modifiers = {
          mandatory = [ "shift" ];
          optional = [ "caps_lock" ];
        };
      };
      to = [
        {
          key_code = k;
        }
      ];
      type = "basic";
    }) digits);

  complexModificationsRules = [
    {
      description = "Exchange numbers and symbols (1234567890 and !@#$%^&*())";
      manipulators = exchangeNumbersAndSymbolsManipulators;
    }
    {
      description = "Change spacebar to left_shift. (Post spacebar if pressed alone)";
      manipulators = [
        {
          from = {
            key_code = "spacebar";
            modifiers = {
              optional = [ "any" ];
            };
          };
          to = [ { key_code = "left_shift"; } ];
          to_if_alone = [ { key_code = "spacebar"; } ];
          type = "basic";
        }
      ];
    }
    {
      description = "コマンドキーを単体で押したときに、英数・かなキーを送信する。（左コマンドキーは英数、右コマンドキーはかな）";
      manipulators = [
        {
          from = {
            key_code = "left_command";
            modifiers = {
              optional = [ "any" ];
            };
          };
          to = [ { key_code = "left_command"; } ];
          to_if_alone = [ { key_code = "japanese_eisuu"; } ];
          type = "basic";
        }
        {
          from = {
            key_code = "right_command";
            modifiers = {
              optional = [ "any" ];
            };
          };
          to = [ { key_code = "right_command"; } ];
          to_if_alone = [ { key_code = "japanese_kana"; } ];
          type = "basic";
        }
      ];
    }
  ];

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
        parameters = {
          delay_milliseconds_before_open_device = 1000;
        };
        virtual_hid_keyboard = {
          caps_lock_delay_milliseconds = 0;
          country_code = 0;
          indicate_sticky_modifier_keys_state = true;
          keyboard_type = "ansi";
          mouse_key_xy_scale = 100;
          standalone_keys_delay_milliseconds = 200;
        };
        complex_modifications = {
          parameters = {
            "basic.simultaneous_threshold_milliseconds" = 50;
            "basic.to_delayed_action_delay_milliseconds" = 500;
            "basic.to_if_alone_timeout_milliseconds" = 1000;
            "basic.to_if_held_down_threshold_milliseconds" = 500;
            "mouse_motion_to_scroll.speed" = 100;
          };
          rules = complexModificationsRules;
        };
        fn_function_keys = fnFunctionKeys;
        devices = [
          {
            disable_built_in_keyboard_if_exists = false;
            fn_function_keys = [ ];
            identifiers = {
              is_keyboard = true;
              is_pointing_device = false;
              product_id = 4871;
              vendor_id = 65261;
            };
            ignore = false;
            manipulate_caps_lock_led = false;
            simple_modifications = [ ];
          }
          {
            disable_built_in_keyboard_if_exists = false;
            fn_function_keys = [ ];
            identifiers = {
              is_keyboard = true;
              is_pointing_device = false;
              product_id = 631;
              vendor_id = 1452;
            };
            ignore = false;
            manipulate_caps_lock_led = true;
            simple_modifications = dvorakSimpleModifications;
          }
          {
            disable_built_in_keyboard_if_exists = false;
            fn_function_keys = [ ];
            identifiers = {
              is_keyboard = true;
              is_pointing_device = false;
              product_id = 256;
              vendor_id = 2131;
            };
            ignore = false;
            manipulate_caps_lock_led = false;
            simple_modifications = dvorakSimpleModifications;
          }
          {
            disable_built_in_keyboard_if_exists = false;
            fn_function_keys = [ ];
            identifiers = {
              is_keyboard = true;
              is_pointing_device = false;
              product_id = 627;
              vendor_id = 1452;
            };
            ignore = false;
            manipulate_caps_lock_led = true;
            simple_modifications = dvorakSimpleModifications;
          }
          {
            disable_built_in_keyboard_if_exists = false;
            fn_function_keys = [ ];
            identifiers = {
              is_keyboard = true;
              is_pointing_device = false;
              product_id = 635;
              vendor_id = 1452;
            };
            ignore = false;
            manipulate_caps_lock_led = true;
            simple_modifications = dvorakSimpleModifications;
          }
          {
            disable_built_in_keyboard_if_exists = false;
            fn_function_keys = [ ];
            identifiers = {
              is_keyboard = true;
              is_pointing_device = false;
              product_id = 641;
              vendor_id = 1452;
            };
            ignore = false;
            manipulate_caps_lock_led = true;
            simple_modifications = dvorakSimpleModifications;
          }
        ];
        one_to_many_mappings = { };
        simple_modifications = [ ];
      }
      {
        name = "vanilla";
        selected = false;
        parameters = {
          delay_milliseconds_before_open_device = 1000;
        };
        virtual_hid_keyboard = {
          caps_lock_delay_milliseconds = 0;
          country_code = 0;
          indicate_sticky_modifier_keys_state = true;
          keyboard_type = "ansi";
          mouse_key_xy_scale = 100;
          standalone_keys_delay_milliseconds = 200;
        };
        complex_modifications = {
          parameters = {
            "basic.simultaneous_threshold_milliseconds" = 50;
            "basic.to_delayed_action_delay_milliseconds" = 500;
            "basic.to_if_alone_timeout_milliseconds" = 1000;
            "basic.to_if_held_down_threshold_milliseconds" = 500;
            "mouse_motion_to_scroll.speed" = 100;
          };
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
