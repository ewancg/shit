# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, config, ... }:

{
  imports =
    [
      # All hardware, network and miscellaneous system-level declarations

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

  # https://nixos.wiki/wiki/MPD#PipeWire
  services.mpd.user = "ewan";
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.ewan.uid}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
  };


  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # User / Authentication
  #services.pcscd.enable = true;
  #hardware.gpgSmartcards.enable = true; # for yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];

  security.pam.u2f.enable = true;
  #security.pam.u2f.authFile = /etc/u2f_mappings;
  security.pam.u2f.settings.authfile = "/etc/u2f_mappings";
  #security.pam.u2f.interactive = true;

  services.displayManager = {
    enable = true;
    
    defaultSession = "hyprland";
  };
  services.xserver.displayManager = {
    gdm.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  security.polkit.enable = true;

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

  boot.supportedFilesystems = [ "ntfs" "sshfs" "btrfs" ];
  # boot.supportedFilesystems = [ "ntfs" "sshfs" "zfs" ];

  # Extra kernel modules
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };
}
