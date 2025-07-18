{ config
, pkgs
, lib
, modulesPath
, ...
}:
let
  memory = "15360M";
  gamePort = 22810;
  #	rconPort = 25575;
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

  # Minecraft
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    user = "minecraft";

    dataDir = "/opt/minecraft/servers";

    servers.computer = {
      enable = true;
      autoStart = true;
      # restart = "always";
      enableReload = true;

      package = pkgs.paperServers.paper-1_21_7;

      jvmOpts = "-Xms${memory} -Xmx${memory} -XX:+UseZGC -XX:+ZGenerational -XX:+UseTransparentHugePages";

      whitelist = {
        EwanGreen4 = "06153161-7095-4a75-8fe9-26a762000325";
        EwanGreen05 = "0f520ab0-7237-43d5-9440-bbce8c8275eb";

        DrFartus = "46a067f3-ea18-483d-b96b-511c17f77f8d";
        RM_Runix = "9583e2fd-d544-43c1-89e5-4b7dfd8a729f";
      };

      serverProperties = {
        server-port = gamePort;
        motd = "GET READY TO PLAY";

        gamemode = "survival";

        white-list = true;
      };

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
          CoreProtect = builtins.fetchurl {
            name = "coreprotect";
            url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/XGIsoVGT/starlight-1.1.2%2Bfabric.dbc156f.jar";
            sha256 = "sha256:1n4292qmcb570llhsarsjg3agr0r25sh5sjhq3pfvfbrc8jv0jrb";
          };
        });
      };
    };
  };
}
