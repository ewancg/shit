# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, ... }:

{
  imports =
    [
      # All hardware, network and miscellaneous system-level declarations
      ./system.nix

      # GNOME
      #      ./desktop/gnome.nix

      # Hyprland
      ./desktop/hyprland.nix

      # System-wide packages
      ./packages.nix
    ];

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  #  services.spotifyd = {
  #  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8d82561f-b4a6-41fb-a200-3e4039a995de";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/71331833-459a-4a50-afab-b07a1800bb63";
    label = "Data";
    fsType = "ext4";
    neededForBoot = true;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "discard"
      "data=ordered"
    ];
  };

  fileSystems."/mnt/work" = {
    label = "Projects";
    device = "/dev/disk/by-uuid/0A10902A10901F2F";
    options = [
      "defaults"
      "nodev"
      "noatime"
      "discard"
      "data=ordered"
    ];
  };

  fileSystems."/mnt/music" = {
    label = "Music (@slave)";
    device = "ewan@slave:/mnt/music";
    fsType = "sshfs";
    options = [
      "reconnect"
      "nodev"
      "nofail"
      "noatime"
      "allow_other"
      "transform_symlinks"
      "ServerAliveInterval=1"
      "Compression=no" # Required, for some reason
      "IdentityFile=/home/ewan/.ssh/id_ed25519"
    ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # User / Authentication
  #services.pcscd.enable = true;
  #hardware.gpgSmartcards.enable = true; # for yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];

  security.pam.u2f.enable = true;
  #security.pam.u2f.authFile = /etc/u2f_mappings;
  security.pam.u2f.settings.authfile = "/etc/u2f_mappings";
  #security.pam.u2f.interactive = true;

  services.gnome.gnome-keyring.enable = true;

  security.pam.services = {
    login.enableGnomeKeyring = true;
    sudo.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    gdm.u2fAuth = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  users.users.ewan = {
    isNormalUser = true;
    initialPassword = "ewan";
    description = "Ewan Green";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  systemd.user.timers."restart-gpg-agent" = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      Unit = "restart-gpg-agent.service";
    };
  };

  systemd.user.services."restart-gpg-agent" = {
    enable = true;
    script = ''
      ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
  
  # Apps
  # Fishy 
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.variables = {
  # 
  # };

  services.flatpak.enable = true;
  # over

  #services.desktopManager.lomiri.enable = true;
  #xdg.portal.enable = true;
  #xdg.portal.extraPortals = (with pkgs;[ xdg-desktop-portal-gtk ]);


  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  programs.steam = {
    enable = true;
    package = with pkgs; steam.override { extraPkgs = pkgs: [ attr ]; };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?


}
