{ config
, pkgs
, lib
, modulesPath
, secrets
, ...
}:
let
  totalMinecraftMemoryMiB = lib.lists.foldl' (acc: server: acc + server.memoryMiB) 0 (lib.attrValues secrets.minecraft.servers);
  serverNames = [ "computer1" "family" ];

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
  boot.kernelParams = [ "hugepagesz=${builtins.toString totalMinecraftMemoryMiB}" "hugepages=${builtins.toString (builtins.floor (builtins.div totalMinecraftMemoryMiB 1024))}" ];

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

    servers = lib.genAttrs serverNames (name: import (./mc-servers + "/${name}/config.nix") { inherit pkgs config secrets; });
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
