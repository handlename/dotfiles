{ lib }:

rec {
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

  keyboards = {
    appleInternal1 = {
      vendor_id = 1452;
      product_id = 631;
    };
    appleInternal2 = {
      vendor_id = 1452;
      product_id = 627;
    };
    magicKeyboard1 = {
      vendor_id = 1452;
      product_id = 635;
    };
    magicKeyboard2 = {
      vendor_id = 1452;
      product_id = 641;
    };
    customKeyboard = {
      vendor_id = 65261;
      product_id = 4871;
    };
  };

  mkKeyboard =
    {
      identifiers,
      manipulate_caps_lock_led ? true,
      simple_modifications ? [ ],
    }:
    {
      disable_built_in_keyboard_if_exists = false;
      fn_function_keys = [ ];
      identifiers = {
        inherit (identifiers) vendor_id product_id;
        is_keyboard = true;
        is_pointing_device = false;
      };
      ignore = false;
      inherit manipulate_caps_lock_led simple_modifications;
    };
}
