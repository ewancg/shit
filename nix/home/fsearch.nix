{ pkgs, ... }:
{
  systemd.user.timers."fsearch-index-update" = {
    Install.WantedBy = [ "basic.target" ];
    Unit.Description = "FSearch - Periodically update database";
    Timer = {
      OnBootSec = "10min";
      OnUnitActiveSec = "30min";
    };
  };
  systemd.user.services."fsearch-index-update" = {
    Install.WantedBy = [ "default.target" ];
    Unit.Description = "Update FSearch's file index";
    Service = {
      Environment = "G_MESSAGES_DEBUG=all";
      ExecStart = ''${pkgs.fsearch}/bin/fsearch --update-database'';
    };
  };

  home.packages = [ pkgs.fsearch ];
}
