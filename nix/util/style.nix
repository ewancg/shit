{ ... }:
let
  ## Convert 1 byte of hex into its decimal representation
  hexToDecimal =
    hex:
    let
      hexMap = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
      firstDigit = hexMap.${builtins.substring 0 1 hex};
      secondDigit = hexMap.${builtins.substring 1 1 hex};
    in
    16 * firstDigit + secondDigit;

  # Convert 3 bytes of hex info denoting a 24 bit color into each value's decimal form (`r,g,b`)
  hexColorToDecimalTriplet =
    hex:
    let
      r = hexToDecimal (builtins.substring 0 2 hex);
      g = hexToDecimal (builtins.substring 2 4 hex);
      b = hexToDecimal (builtins.substring 4 6 hex);
    in
    "${toString r},${toString g},${toString b}";
in
{
  inherit hexToDecimal hexColorToDecimalTriplet;
}
