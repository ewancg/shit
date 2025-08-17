{ config
, pkgs
, lib
, modulesPath
, secrets
, ...
}:
let
  memoryMiB = secrets.minecraft.memoryMiB;
  memoryJavaArg = "${builtins.toString memoryMiB}M";

  socketPath = "/run/minecraft";
  socket = "${socketPath}/computer.sock";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk.nix
  ];

  security.sudo.wheelNeedsPassword = false;

  # # Secrets
  # sops.defaultSopsFile = ./secrets.yaml;
  # # This will automatically import SSH keys as age keys
  # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # # This will generate a new key if the key specified above does not exist
  # sops.age.generateKey = true;
  # # This is the actual specification of the secrets.
  # sops.secrets."rcon-password" = {};
  #
  # sops.secrets."secrets.yaml" = {
  #   restartUnits = [ "minecraft1.service" ];
  #   # there is also `reloadUnits` which acts like a `reloadTrigger` in a NixOS systemd service
  # };

  # No longer on EC2
  # imports = [
  #   "${modulesPath}/virtualisation/amazon-image.nix"
  # ];
  # ec2.efi = true;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh = {
    enable = true;
    settings = {
      # Allow inheriting remote accessor's relevant variables
      AcceptEnv = "LANG LC_* MCA_*";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [ secrets.adminPubKey ];
  users.users.minecraft.openssh.authorizedKeys.keys = [ secrets.adminPubKey ];

  system.stateVersion = "25.11";
  boot.kernelParams = [ "hugepagesz=${builtins.toString memoryMiB}" "hugepages=${builtins.toString (builtins.floor (builtins.div memoryMiB 1024))}" ];

  environment.systemPackages = with pkgs; map lib.lowPrio [
    curl
    gitMinimal

    tmux
    temurin-bin-24
  ];

  networking.firewall = {
    enable = true;
  };

  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
  };

  # Minecraft
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    #user = "root";
    user = "minecraft";

    servers.computer1 = {
      enable = true;
      autoStart = true;
      restart = "no";
      enableReload = true;

      managementSystem.tmux.enable = false;
      managementSystem.systemd-socket.enable = true;
      package = pkgs.paperServers.paper-1_21_8;

      jvmOpts = "-Xms${memoryJavaArg} -Xmx${memoryJavaArg} -XX:+UseZGC -XX:+ZGenerational -XX:+UseTransparentHugePages";

      # Disabled since CoreProtect is enabled
      # whitelist = secrets.minecraft.whitelist;

      serverProperties = {
        server-port = secrets.minecraft.gamePort;

        enable-rcon = true;
        rcon-port = secrets.minecraft.rconPort;
        rcon-password = secrets.minecraft.rconPassword;

        motd = "GET READY TO PLAY";

        gamemode = "survival";
        simulation-distance = 20;

        white-list = false;
      };

      symlinks = import ./plugins.nix { inherit pkgs; };
      files = {
        "config/Essentials/config.yml".value = {
          notify-no-new-mail = false;
          per-player-locale = true;

          message-colors = {
            primary = "#AEEFD1";
            secondary = "#FFAFAF";
          };

          # Name related
          ops-name-color = "none";
          max-nick-length = "25";
          nickname-prefix = "";
          real-names-on-list = true;

          auto-afk-timeout = 10;
          broadcast-afk-message = false;
          send-info-after-death = true;

          update-check = false;

          backup = {
            interval = secrets.backup.intervalMinutes;
            always-run = false;
            command = "/srv/minecraft/backup";
          };
        };

        "config/EssentialsDiscord/config.yml".value = {
          token = secrets.discord.applicationToken;
          guild = secrets.discord.server.id;

          channels = {
            primary = secrets.discord.server.generalChannelId;
            staff = secrets.discord.server.staffChannelId;
          };

          message-types = {
            chat =  "primary";
            join =  "primary";
            leave = "primary";
            death = "primary";
            kick =  "staff";
            mute =  "staff";
          };
        };

        # Permissions will be stored and managed via. database instead of config file.
        "config/LuckPerms/config.yml".value = {
          server = "computer1";
          storage-method = "postgresql";
          data = {
            address = "localhost";
            database = secrets.postgres.database;
            username = secrets.postgres.user;
            password = secrets.postgres.password;
          };
          auto-op = true;
        };
      };
    };
  };

  # Server monitor script (two-pane input/output with tmux)
  systemd.tmpfiles.rules = [
    "d /run/minecraft 0777 minecraft minecraft -"
    "f /run/minecraft/monitor 0755 minecraft - - ${pkgs.writeScript "mc-monitor" ''
      #!/usr/bin/env bash
      if [ ! -d "/srv/minecraft/$1" ]; then
          [[ -z "$1" ]] && echo "No Minecraft server name provided." || echo "No Minecraft server with the given name."
          exit
      fi

      SESSION="mc-monitor-$1"
      tmux kill-session -t "$SESSION" 2>/dev/null

      # logs in the top pane
      tmux new-session -d -s "$SESSION" "bash -c 'printf \"\e]0;output\a\"; exec journalctl --output cat -f -u \"*$1*\"'"
      # input in the bottom pane
      tmux split-window -v -t "$SESSION" "bash -c '
        printf \"\e]0;input\a\";
        stty sane;
        printf \"\e[2K\r\";
        while true; do
          trap \"exit 0\" INT;
          IFS= read -er cmd;
          printf \"\e[2K\r\";
          echo \"\$cmd\" > /run/minecraft/$1.stdin;
        done
      '"
      tmux resize-pane -t "$SESSION:0.1" -y 1

      tmux set-option -t "$SESSION" pane-border-status top
      tmux set-option -t "$SESSION" pane-border-format "┤ #{pane_title} ├"

      tmux set-option -t "$SESSION" status on
      tmux set-option -t "$SESSION" status-interval 60
      tmux set-option -t "$SESSION" status-left-length 0
      tmux set-option -t "$SESSION" status-right-length 0
      tmux set-option -t "$SESSION" status-format[0] "#[align=centre]#S"

      # session termination
      tmux set-hook -t "$SESSION" pane-exited "kill-session -t $SESSION"

      tmux set-option -t "$SESSION" mouse off

      tmux attach -t "$SESSION"
    ''} $@"
  ];
}
