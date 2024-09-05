{ ... }:

{
  imports = [
    # DoH settings
    ../dns.nix

    # Apple AirPlay 2 settings
    ../uxplay.nix
  ];

  networking = {
    hostName = "machine";
    enableIPv6 = true;

    # Conflict: set to false by NetworkManager
    # useDHCP = true;

    dhcpcd = {
      enable = true;
      persistent = true;
    };

    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
    };

    nftables = {
      enable = true;
    };

    # https://nixos.wiki/wiki/Networking
    # consider NAT port forwards
    firewall = {
      allowedTCPPorts = [
        # Not Soulseek
        2234
      ];
      allowedTCPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];

      allowedUDPPorts = [
        # UxPlay / AirPlay 2
        5353
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];
    };
  };
}
