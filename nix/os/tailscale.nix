{ config, ... }:
let
  tailnet = "ewancg.github";
in
{
  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };

  # Uncomment if using exit nodes blocks internet traffic
  # networking.firewall.checkReversePath = "loose";

  # Periodically checks if the certificate is near expiry, and renews as needed
  # Runs more frequently than the certificates expire since there is no way to
  # express a persistent 90 day timer with systemd timers.
  # systemd.services."tailscale-check-tls" = {
  #   script = ''
  #       expiry="$()"
  #
  #       tailscale cert ${config.lib.networking.hostName}.${tailnet}
  #   '';
  #   serviceConfig = {
  #     User = "root";
  #   };
  #   timerConfig = {
  #     OnCalendar = "weekly";
  #     Persistent = true;
  #   };
  # };
}
