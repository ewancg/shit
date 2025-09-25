{
  pkgs,
  lib,
  secrets,
  firefox,
  util,
  ...
}:

let
  english = "en_US.UTF-8";
  locale-variables = {
    # LC_ALL            = "";
    LANG = english;
    LANGUAGE = english;
    LC_ADDRESS = english;
    LC_CTYPE = english;
    LC_IDENTIFICATION = english;
    LC_MEASUREMENT = english;
    LC_MONETARY = english;
    LC_NAME = english;
    LC_NUMERIC = english;
    LC_PAPER = english;
    LC_TELEPHONE = english;
    LC_TIME = english;
  };
in
{

  system.stateVersion = "24.05";

  imports = [
    # All hardware, network and miscellaneous system-level declarations

    # Desktop; hyprland.nix or gnome.nix
    ./desktop/hyprland.nix

    # Home Manager accommodations
    ../home/desktop-accommodations.nix
    ../home/apps-accommodations.nix
    ../home/office-accommodations.nix
    ../home/base-accommodations.nix
  ];

  # temp
  services.logrotate.checkConfig = false;
  environment.systemPackages = with pkgs; [
    # nixos
    nh

    # linux/system
    libnotify
    at
    kdePackages.kde-cli-tools
    patchelf
    bridge-utils
    libvirt
    avahi-compat
    bind
    binutils
    btrfs-progs
    fuse
    mkinitcpio-nfs-utils
    nfs-utils
    sshfs-fuse
    sshpass
    udisks
    v4l-utils
    lshw
    dhcpcd
    usbutils # lsusb
    openssl
    pciutils
    udisks
  ];

  hardware.enableAllFirmware = true;
  boot.supportedFilesystems = [
    "ntfs"
    "sshfs"
    "btrfs"
  ];

  # Extra kernel modules
  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
  ];

  # Time zone
  time.timeZone = "America/Denver";

  # Internationalisation properties
  i18n.defaultLocale = english;
  i18n.supportedLocales = [ "${english}/UTF-8" ];
  i18n.extraLocaleSettings = locale-variables;

  # Keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  services.seatd = {
    enable = true;
  };

  services.cachix-agent.enable = true;

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    # package = pkgs.nixVersions.stable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    #settings.experimental-features = [ "nix-command" "flakes" ];

    settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  # fileSystems."/mnt/music" = {
  #   device = "ewan@slave.local:/mnt/music";
  #   fsType = "sshfs";
  #   options = [
  #     "reconnect"
  #     "nodev"
  #     "nofail"
  #     "noatime"
  #     "allow_other"
  #     "transform_symlinks"
  #     "ServerAliveInterval=1"
  #     "Compression=no" # Required, for some reason
  #     "IdentityFile=/home/ewan/.ssh/id_ed25519"
  #   ];
  # };

  # https://nixos.wiki/wiki/MPD#PipeWire
  #services.mpd.user = "ewan";
  #systemd.services.mpd.environment = {
  #  XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.ewan.uid}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
  #};

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # User / Authentication
  #services.pcscd.enable = true;
  #hardware.gpgSmartcards.enable = true; # for yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];

  security.pam.u2f.enable = true;
  #security.pam.u2f.authFile = /etc/u2f_mappings;

  security.pam.u2f.settings.authfile = "${
    let
      m = secrets.u2fMappings;
      text =
        if builtins.isString m then
          m
        else if builtins.isAttrs m then
          (lib.concatMapAttrsStringSep "\n" (
            name: value: with value; "${name}:${keyHandle},${userKey},${coseType},${options}"
          ) secrets.u2fMappings)
          + "\n"
        else
          throw "secrets.u2fMappings was neither a string or attribute set.";
    in
    pkgs.writeText "u2f_mappings" text
  }";
  security.pam.u2f.settings.interactive = false;
  security.pam.u2f.control = "sufficient";

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  services.displayManager = {
    enable = true;

    defaultSession = "hyprland-uwsm";
  };
  services.displayManager = {
    gdm.enable = true;
  };

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

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addAdminRule(function(action, subject) {
        if( subject.isInGroup("wheel") ) {
          return ["unix-user:"+subject.user];
        }
        else {
          return [polkit.Result.NO];
        }
      });
    '';
  };

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

  users = {
    mutableUsers = false;
    groups.ewan = { };

    users.root.hashedPasswordFile = (util.password "root");

    users.ewan = {
      group = "ewan";
      home = "/home/ewan";
      isNormalUser = true;
      hashedPasswordFile = (util.password "ewan");
      description = "Ewan Green";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "ewan"
      ];
    };
    groups.egreen = { };
    users.egreen = {
      group = "egreen";
      home = "/home/egreen";
      isNormalUser = true;
      hashedPasswordFile = (util.password "egreen");
      description = "Ewan Green (Office)";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "egreen"
      ];
    };
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

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  # Apps
  # Fishy
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Install firefox.
  programs.firefox = {
    enable = true;
    package = firefox.packages.${pkgs.system}.firefox-nightly-bin;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;
  # over

  #services.desktopManager.lomiri.enable = true;
  #xdg.portal.enable = true;
  #xdg.portal.extraPortals = (with pkgs;[ xdg-desktop-portal-gtk ]);

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # programs.steam = {
  #   enable = true;
  #   package = with pkgs; steam.override { extraPkgs = pkgs: [ attr ]; };
  # };

  # alacritty for nautilus
  programs.nautilus-open-any-terminal.enable = true;

  boot.initrd.systemd.enable = true;
  #swapDevices = [{ device = "/var/swapfile"; size = 64 * 1024; }];
  #boot.resumeDevice = "/dev/nvme1n1p1";
  # hibernate
  boot.kernelParams = [
    "mem_sleep_default=deep"
    # For mouse & audio interface idle
    "usbcore.autosuspend=120"
  ];
  # suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
