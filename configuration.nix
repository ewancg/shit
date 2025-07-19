{ config
, pkgs
, lib
, modulesPath
, ...
}:
let
  memory = 14336;
  gamePort = 22810;
  #	rconPort = 25575;
  coreProtect = builtins.fetchurl {
    url = "https://ci.ecocitycraft.com/job/CoreProtect/lastSuccessfulBuild/artifact/target/CoreProtect-23.0.jar";
    sha256 = "sha256:0q39n2p99sakr2h1lv3vwrn5d87zv4a8vj8sgmz8lm82q5l6jhf9";
  };
  socketPath = "/run/minecraft";
  socket = "${socketPath}/computer.sock";
in
{
  system.stateVersion = "25.11";
  boot.kernelParams = [ "hugepagesz=${memory}" "hugepages=15" ];

  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];
  ec2.efi = true;

  environment.systemPackages = with pkgs; [
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
      # managementSystem.systemd-socket = {
      #   enable = true;
      #   stdinSocket.path = server: socket;
      # };

      package = pkgs.paperServers.paper-1_21_7;

      jvmOpts = "-Xms${memory}M -Xmx${memory}M -XX:+UseZGC -XX:+ZGenerational -XX:+UseTransparentHugePages";

      whitelist = {
        EwanGreen4 = "06153161-7095-4a75-8fe9-26a762000325";
        EwanGreen05 = "0f520ab0-7237-43d5-9440-bbce8c8275eb";
        FNL2 = "25d1b66a-e2d7-4884-b9b0-9e77e31cd4c3";
        DrFartus = "46a067f3-ea18-483d-b96b-511c17f77f8d";
        RM_Runix = "9583e2fd-d544-43c1-89e5-4b7dfd8a729f";
      };

      serverProperties = {
        server-port = gamePort;
        motd = "GET READY TO PLAY";

        gamemode = "survival";
        simulation-distance = 20;

        white-list = true;
      };

      # symlinks = {
      #   "plugins/CoreProtect.jar" = coreProtect;
      # };
    };
  };
}
