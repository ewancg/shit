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

  # Connection sharing
  # Set a static IP on the "downstream" interface
  networking.interfaces."enp13s0f4u2u1" = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "10.0.0.1";
      prefixLength = 24;
    }];
  };
  networking.firewall.trustedInterfaces = [ "enp13s0f4u2u1" ];
  networking.firewall.extraForwardRules = ''
    type nat hook postrouting priority srcnat; policy accept;
    oifname { "enp13s0f4u2u1" } masquerade
  '';
  # networking.firewall.extraCommands = ''
  #   # Set up SNAT on packets going from downstream to the wider internet
  #   iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
  # '';
  # Run a DHCP server on the downstream interface
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "enp13s0f4u2u1"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          id = 1;
          pools = [
            {
              pool = "10.0.0.2 - 10.0.0.255";
            }
          ];
          subnet = "10.0.0.1/24";
        }
      ];
      valid-lifetime = 4000;
      option-data = [{
        name = "routers";
        data = "10.0.0.1";
      }];
    };
  };
}
