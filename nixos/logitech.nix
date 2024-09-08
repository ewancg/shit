{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    solaar
    v4l2-relayd
  ];
  
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  services.v4l2-relayd.instances."C920" = {
    cardLabel = "C920 Webcam";
    input.width = 1280;
    input.height = 720;
    input.framerate = 60;
    input.format = "h.264";
    output.format = "h.264";
  };
}
