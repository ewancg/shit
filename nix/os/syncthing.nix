{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  environment.systemPackages = [ pkgs.syncthing ];
  services = {
    syncthing = {
        enable = true;
        group = "ewan";
        user = "ewan";
        dataDir = "/home/ewan/Shared";
        configDir = "/home/ewan/Shared/.config/syncthing";
    };
  };
}