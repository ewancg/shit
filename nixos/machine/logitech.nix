{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    logiops
    ];
  # add config
 #  hardware.logitech.wireless.enable = true;
 #  hardware.logitech.wireless.enableGraphical = true;
}