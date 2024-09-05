{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.solaar
  ];
  
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}
