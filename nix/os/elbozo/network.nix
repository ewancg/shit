{ config, pkgs, ... }:

{
  networking = {
    # IPs subject to change, should use DHCP
    hosts = {
      "10.0.0.58" = [ "machine" ];
      "10.0.0.81" = [ "slave" ];
    };

    # Prefer DoH above
    #nameservers = [
    #  # OpenDNS
    #  "208.67.222.222" 
    #  "208.67.220.220"
    #];

    hostName = "elbozo";
    enableIPv6 = true;
    #  useDHCP = true;

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
  };
  # DNS
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";

        # From https://github.com/DNSCrypt/dnscrypt-resolvers/
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      server_names = [
        "dnscry.pt-denver-ipv4"
        "cisco-ipv6-doh"
      ];

      #forwarding_rules = "/etc/nixos/services/forwarding-rules.txt";
    };
  };

  environment.etc."nixos/services/forwarding-rules.txt" = {
    mode = "0777";
    text = ''
      local            192.168.1.1
    '';
  };
}
