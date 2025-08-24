{ secrets, pkgs, ... }:
let
    server = secrets.minecraft.servers.computer1;
    memoryJavaArg = "${builtins.toString server.memoryMiB}M";
in
{
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
    server-port = server.gamePort;

    enable-rcon = false;
    # rcon-port = server.rconPort;
    # rcon-password = server.rconPassword;

    motd = "GET READY TO PLAY";

    gamemode = "survival";
    simulation-distance = 20;

    white-list = false;
  };

  symlinks = import ./plugins.nix { inherit pkgs; };
  files = {
    "plugins/Essentials/config.yml".value = {
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
        command = "${pkgs.bash}/bin/bash /run/minecraft/backup";
      };
    };

    "plugins/DiscordSRV/config.yml".value = {
      UpdateCheckDisabled = true;
      MetricsDisabled = true;

      BotToken = secrets.discord.applicationToken;
      DiscordConsoleChannelId = secrets.discord.server.consoleChannelId;

      Channels = {
        "global" = secrets.discord.server.generalChannelId;
        "admin" = secrets.discord.server.staffChannelId;
      };

      # rip
      # Experiment_JdbcAccountLinkBackend = "jdbc:postgresql://localhost:${builtins.toString secrets.postgres.port}/${secrets.postgres.database}?autoReconnect=true&useSSL=false";
      # Experiment_JdbcTablePrefix = "discordsrv";
      # Experiment_JdbcUsername = secrets.postgres.user;
      # Experiment_JdbcPassword = secrets.postgres.password;
    };

    "plugins/DiscordSRV/messages.yml".value = let
      mtd = "[%displayname%] %message%";
      dtm = "[d: %name%] %message%";
    in {
      DiscordToMinecraftChatMessageFormat = dtm;
      DiscordToMinecraftChatMessageFormatNoRole = dtm;
      MinecraftChatToDiscordMessageFormat = mtd;
      MinecraftChatToDiscordMessageFormatNoPrimaryGroup = mtd;
    };

    # Permissions will be stored and managed via. database instead of config file.
    "plugins/LuckPerms/config.yml".value = {
      server = "computer1";
      storage-method = "postgresql";
      data = {
        address = "127.0.0.1:${builtins.toString secrets.postgres.port}";
        database = secrets.postgres.database;
        username = secrets.postgres.user;
        password = secrets.postgres.password;
      };
      auto-op = true;
    };
  };
}
