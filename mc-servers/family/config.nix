{ secrets, config, pkgs, ... }:
let
    server = secrets.minecraft.servers.family;
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

    motd = "it's minecraft";

    gamemode = "survival";
    simulation-distance = 20;

    white-list = false;
  };

  symlinks = import ./plugins.nix { inherit pkgs; };
  files = {
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
