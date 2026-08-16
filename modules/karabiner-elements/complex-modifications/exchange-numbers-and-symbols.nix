let
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
in
{
  description = "Exchange numbers and symbols (1234567890 and !@#$%^&*())";
  manipulators =
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
}
