{ lib, ... }:
{
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    dhcpcd.enable = true;
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
  };

  # Check!
  services.resolved.enable = false;

  # To enable network-discovery; required for *.local, AirPlay, etc.
  services.avahi = {
    enable = true;
    nssmdns4 = true; # printing; *.local
    openFirewall = true; # ensuring that firewall ports are open as needed
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
      domain = true;
    };
  };

  # IPs subject to change. should use hostname.local from Avahi instead
  # hosts = {
  #   "10.0.0.81" = [ "slave" ];
  # };

  # Prefer DoH below
  # nameservers = [
  #   # OpenDNS
  #   "208.67.222.222"
  #   "208.67.220.220"
  # ];

  # For whatever reason, the proxy is not able to open this file even when we set the mode.
  # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-forwarding-rules.txt
  environment.etc."nixos/services/forwarding-rules.txt" = {
    mode = "0644";
    text = ''
      lan              192.168.1.1
      local            192.168.1.1
      home             192.168.1.1
      home.arpa        192.168.1.1
      internal         192.168.1.1
      localdomain      192.168.1.1
      192.in-addr.arpa 192.168.1.1
      example.com      9.9.9.9,8.8.8.8
      ipv6.example.com [2001:DB8::42]:53
      onion            127.0.0.1:9053
    '';
  };

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      # 1.1.1.1 important; neither of the other 2 worked for me in canyon
      bootstrap_resolvers = [
        "1.1.1.1:53"
        "9.9.9.9:53"
        "8.8.8.8:53"
      ];
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
        "mullvad-base-doh"
        "dnscry.pt-denver-ipv4"
        "dnscry.pt-denver-ipv6"
      ];

      # Defined above
      #      forwarding_rules = "/etc/nixos/services/forwarding-rules.txt";
    };
  };
}
