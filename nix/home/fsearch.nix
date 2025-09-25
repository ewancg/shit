{ pkgs, ... }:
{
  systemd.services = {
    fsearch-schedule-index-update = {
      wantedBy = [ "basic.target" ];
      description = "FSearch - Periodically update database";
      timerConfig = {
        OnBootSec = "10min";
        OnUnitActiveSec = "30min";
      };
    };
    fsearch-index-update = {
      wantedBy = [ "default.target" ];
      description = "Update FSearch's file index";
      serviceConfig = {
        ExecStart = ''${pkgs.fsearch}/bin/fsearch --update-database'';
      };
    };
  };

  environment.systemPackages = [ pkgs.fsearch ];
}
