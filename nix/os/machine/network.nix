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
    enable = false;
    autostart = false;

    interface = {
      privateKeyFile = "/root/protonvpn-us-dc-31-desktop-key";
    };
    endpoint = {
      ip = "185.247.68.50";
      port = 51820;
      publicKey = "3Lz5VpqnS7wfnOWVYFNCFHl+JuuanJ/hB2TqOKQZxVI=";
    };
  };

  services.resolved = {
    enable = false;
    dnsovertls = true;
    llmnr = "true";
    # dnssec = "true";
    # too raw...
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
      # dhcp = "dhcpcd";
      dispatcherScripts = [
        {
          source = (util.script "network-event");
        }
      ];
    };
    nftables = {
      enable = true;
    };
  };
}
