{ secrets, pkgs, lib, ... }: let
    git = lib.getExe pkgs.git;
in {
  networking.nftables.enable = true;

  # services.tailscale.enable = true;
  # services.tailscale.interfaceName = "userspace-networking";


  systemd.tmpfiles.rules = [
    "d /run/minecraft 0777 minecraft minecraft -"
    "d /srv/minecraft 0777 minecraft minecraft -"

    "f /run/minecraft/backup 0755 minecraft - - ${pkgs.writeScript "mc-backup" ''
      #!/usr/bin/env bash
      cd /srv/minecraft

      # restore with
      # psql -X -f perms_database postgres
      pg_dumpall > perms_database

      ${git} add -A
      ${git} commit -m "$(TZ="${secrets.backup.timezone}" date "+%b %d %y, %r %Z")"
      ${git} push
    ''}"

    "f /srv/minecraft/.gitattributes 0644 minecraft - - ${pkgs.writeText "mc-backup-gitattributes" ''
      *.dat filter=lfs diff=lfs merge=lfs -text
      *.dat_old filter=lfs diff=lfs merge=lfs -text
      *.jar filter=lfs diff=lfs merge=lfs -text
      *.jar.disabled filter=lfs diff=lfs merge=lfs -text
      *.mca filter=lfs diff=lfs merge=lfs -text
      *.xz filter=lfs diff=lfs merge=lfs -text
      *.zip filter=lfs diff=lfs merge=lfs -text
    ''}"

    "f /srv/minecraft/.gitignore 0644 minecraft - - ${pkgs.writeText "mc-backup-gitignore" ''
      backup
      monitor
      session.lock
    ''}"

  ];

  system.activationScripts = {
    minecraft-backup-lfs = {
      text =
        ''
          #!/usr/bin/env bash

          cd /srv/minecraft
          if [ ! -d ".git" ]; then
            ${git} init
            ${git} remote add origin ${secrets.backup.gitRepo}
            ${git} switch ${secrets.backup.gitBranch}
            ${git} pull
          fi
        '';
    };
  };

  programs.git = {
    enable = true;
    lfs = {
      enable = true;
    };
    config = {
      user.name = secrets.backup.gitUsername;
      user.email = secrets.backup.gitEmail;
    };
  };
}
