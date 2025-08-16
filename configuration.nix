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
  services.openssh.enable = true;

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
      package = pkgs.paperServers.paper-1_21_7;

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
        # "Essentials/config.yml" = {
        #
        # };

        "EssentialsDiscord/config.yml".value = {
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
        "LuckPerms/config.yml".value = {
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
}
