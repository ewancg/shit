{ pkgs, ... }:

{
  # AirPlay
  # Open network ports
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];
  networking.firewall.allowedUDPPorts = [ 5353 6000 6001 7011 ];

  environment.systemPackages = with pkgs; [
    # AirPlay
    uxplay
  ];
}
