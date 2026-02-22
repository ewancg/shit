{ lib
, secrets
, hostname
, util
, ...
}:
let
  s = secrets.s.${hostname}.tailscale;
in
{
  services.tailscale = let use = s.enable; in {
    enable = use;
    openFirewall = use;
    disableUpstreamLogging = use;
    useRoutingFeatures = s.routingFeatures;

    extraDaemonFlags = [
      "--no-logs-no-support"
    ];
    extraUpFlags = [
      (lib.mkIf s.ssh "--ssh")
      (lib.forEach s.users (user: "--operator=${user}"))
    ];
  };

  # Uncomment if using exit nodes blocks internet traffic
  networking.firewall = {
    allowedTCPPorts = lib.mkIf s.ssh [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  systemd = lib.mkIf s.enable (
    let
      tls-service = "tailscale-check-tls";
    in
    {
      services = with util.commands; {
        "tailscale-activation" = {
          description = "Connect to Tailscale and authenticate user";
          after = [
            "network-pre.target"
            "tailscale.service"
          ];
          wants = [
            "network-pre.target"
            "tailscale.service"
          ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = "root";
            Type = "oneshot";
          };
          script = ''
            sleep 2

            status="$(${tailscale} status -json | ${gojq} -r .BackendState)"
            if [ $status != "Running" ]; then
              ${tailscale} up
            fi
          '';
        };

        # Periodically checks if the certificate is near expiry, and renews as needed
        # Runs more frequently than the certificates expire since there is no way to
        # express a persistent X day timer with systemd timers.
        ${tls-service} = {
          description = "Update Tailscale TLS certificates if necessary";
          after = [
            "network-pre.target"
            "tailscale.service"
          ];
          wants = [
            "network-pre.target"
            "tailscale.service"
          ];
          script =
            let
              tfile = "/var/lib/${tls-service}-history";
              interval = "13 days 18 hours"; # expiry window is 14 days
            in
            ''
              renew() {
                ${tailscale} cert ${hostname}.${s.tailnet}
                exit $?
              }

              if [ -f "${tfile}" ]; then
                date() {
                  ${date} +%s "$@"
                }
                last_time="$(< "${tfile}")"
                [ "$last_time" -ge 0 ] 2>/dev/null || renew
                next_time="$(date -d "$last_time + ${interval}")"
                now="$(date)"
                [ "$now" -ge "$next_time" ] && renew
              else
                renew
              fi
            '';
          serviceConfig = {
            User = "root";
            Type = "oneshot";
          };
        };
      };
      timers.${tls-service} = {
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    }
  );
}
