{ pkgs, util, ... }:

{
  imports = [
    # DoH settings
    ../dns.nix

    # Apple AirPlay 2 settings
    ../uxplay.nix

    # File sync
    ../syncthing.nix

    # Tailscale (direct communication with devices on my tailnet, and VPN access)
    ../tailscale.nix

    ../protonvpn.nix
  ];

  environment.systemPackages = with pkgs; [
    # wpa_supplicant_gui
    networkmanagerapplet
  ];

  services.protonvpn = {
    enable = true;
    autostart = true;

    interface = {
      privateKeyFile = "/root/protonvpn-us-dc-31-desktop-key";
    };
    endpoint = {
      ip = "185.247.68.50";
      port = 51820;
      publicKey = "3Lz5VpqnS7wfnOWVYFNCFHl+JuuanJ/hB2TqOKQZxVI=";
    };
  };

  networking = {
    hostName = "machine";
    enableIPv6 = true;

    # Conflict: set to false by NetworkManager
    # useDHCP = true;

    dhcpcd = {
      enable = true;
      persistent = true;
    };

    wireless.iwd.settings = {
      IPv6 = {
        Enabled = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dhcp = "dhcpcd";
      dispatcherScripts =
        let
          source = (util.script "network-event");
        in
        [
          {
            inherit source;
          }
        ];
    };

    # wireless = {
    #   enable = true;
    #   userControlled.enable = true;
    # };

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
        {
          from = 1714;
          to = 1764;
        }
      ];

      allowedUDPPorts = [
        # UxPlay / AirPlay 2
        5353
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        {
          from = 1714;
          to = 1764;
        }
      ];

    };
  };

  # Connection sharing
  # Set a static IP on the "downstream" interface
  # networking.interfaces."enp13s0f4u2u1" = {
  #   useDHCP = false;
  #   ipv4.addresses = [{
  #     address = "10.0.0.1";
  #     prefixLength = 24;
  #   }];
  # };
  #networking.firewall.trustedInterfaces = [ "enp13s0f4u2u1" ];
  #networking.firewall.extraForwardRules = ''
  #  type nat hook postrouting priority srcnat; policy accept;
  #  oifname { "enp13s0f4u2u1" } masquerade
  #'';
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
          #          "enp13s0f4u2u1"
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
      option-data = [
        {
          name = "routers";
          data = "10.0.0.1";
        }
      ];
    };
  };
}
