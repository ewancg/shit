{ secrets, hostname, ... }:
let
  tailscale = secrets.s.${hostname}.tailscale;
in
{
    services.tailscale = {
      enable = tailscale.enable;
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };

  # Uncomment if using exit nodes blocks internet traffic
  # networking.firewall.checkReversePath = "loose";

  # Periodically checks if the certificate is near expiry, and renews as needed
  # Runs more frequently than the certificates expire since there is no way to
  # express a persistent 90 day timer with systemd timers.

  systemd = let service = "tailscale-check-tls"; in {
    services.${service} = {
      description = "Update Tailscale TLS certificates if necessary";
      script = let tfile = "/var/lib/${service}-history"; in ''
        [ -f "${tfile}" ] || touch "${tfile}"


        tailscale cert ${hostname}.${tailscale.tailnet}
      '';
      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };
    };
   timers.${service} = {
     timerConfig = {
       OnCalendar = "weekly";
       Persistent = true;
     };
   };
  };
}
