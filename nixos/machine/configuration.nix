# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, stdenvNoCC, lib, fetchzip, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # GPU
      ./graphics.nix

      # Audio configuration
      ./audio.nix

      # Windows fonts
      #../misc/segoe-ui-variable.nix
    ];


  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  services.udev.extraRules =
    builtins.replaceStrings ["/bin/chmod"] ["${pkgs.coreutils}/bin/chmod"] ''
    ${builtins.readFile ./udev/60-openrgb.rules}
    '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  home-manager = {
    users = {
      "ewan" = import ./home.nix;
    };
  };

fonts.packages = with pkgs; [
  noto-fonts
  #noto-fonts-cjk
  #noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts.githubRelease
  dina-font
  proggyfonts
  corefonts
  vistafonts
];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "machine"; # Define your hostname.
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

    nixpkgs.overlays = [
    # GNOME 46: triple-buffering-v4-46
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab  {
            domain = "gitlab.gnome.org";
            owner = "vanvugt";
            repo = "mutter";
            rev = "triple-buffering-v4-46";
            hash = "sha256-fkPjB/5DPBX06t7yj0Rb3UEuu5b9mu3aS+jhH18+lpI=";
          };
        });
      });
    })
  ];
  nixpkgs.config.allowAliases = false;


programs.nautilus-open-any-terminal = {
  enable = true;
  terminal = "alacritty";
};

environment = {
  #sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${pkgs.gnome.nautilus-python}/lib/nautilus/extensions-4";
  pathsToLink = [
    "/share/nautilus-python/extensions"
  ];

};

  # GNOME settings
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.nautilus.preferences]
    default-folder-viewer='list-view'
    
    [org.gnome.mutter]
    experimental-features="['scale-monitor-framebuffer']"
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # User / Authentication
  #services.pcscd.enable = true;
  #hardware.gpgSmartcards.enable = true; # for yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  
  security.pam.u2f.enable = true;
  #security.pam.u2f.authFile = /etc/u2f_mappings;
  security.pam.u2f.authFile = "/etc/u2f_mappings";
  #security.pam.u2f.interactive = true;
  #security.pam.u2f.debug = true;
  
#  security.pam.services.ewan.enableGnomeKeyring = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
    sudo.enableGnomeKeyring = true;
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  users.users.ewan = {
    isNormalUser = true;
    initialPassword = "ewan";
    description = "Ewan Green";
    extraGroups = [ "networkmanager" "wheel" ];
    #packages = with pkgs; [
      #  thunderbird
    #];
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
  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gnome";
    QT_STYLE_OVERRIDE = "kvantum";
};

services.flatpak.enable = true;
# over

environment.gnome.excludePackages = (with pkgs; [
  gnome-photos
  gnome-tour
]) ++ (with pkgs.gnome; [
  cheese # webcam tool
  gnome-music
  gnome-terminal
  #gedit # text editor
  epiphany # web browser
  geary # email reader
  evince # document viewer
  gnome-characters
  totem # video player
  tali # poker game
  iagno # go game
  hitori # sudoku game
  atomix # puzzle game
]);

  environment.systemPackages = with pkgs; [
    
        gnome.nautilus
    gnome.nautilus-python

    # GNOME & desktop integration
    gnome.dconf-editor
    gnome.gnome-tweaks
    yaru-theme

    qgnomeplatform
    qgnomeplatform-qt6
    xdg-desktop-portal

    # Theming
    gradience 
    adw-gtk3
    libsForQt5.qtstyleplugin-kvantum

    # "Task manager"
    mission-center
    
    # Dev C/C++
    cmake
    gcc
    clang
    ninja
    mold

    nix-index
    nixpkgs-fmt
    nil
    
    wget
    alacritty
    gimp
    git
    #home-manager-path
    lshw
    nil
    nixpkgs-fmt
    normcap
    openrgb
    qpwgraph
    teamspeak_client
    tmux
    
        wine64
    winetricks
    wineWowPackages.staging
    wineWowPackages.waylandFull

    gnupg
    

stdenvNoCC.mkDerivation (finalAttrs: {
    name = "segoe-ui-variable";
    pname = "segoe-ui-variable";
    version = "0-unstable-2024-06-06";

    src = fetchzip {
      url = "https://aka.ms/SegoeUIVariable";
      extension = "zip";
      stripRoot = false;
      hash = "sha256-s82pbi3DQzcV9uP1bySzp9yKyPGkmJ9/m1Q6FRFfGxg=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/{fonts/truetype,licenses/segoe-ui-variable}
      ln -s ${finalAttrs.src}/EULA.txt $out/share/licenses/segoe-ui-variable/LICENSE
      for font in *.ttf; do
      ln -s ${finalAttrs.src}/"$font" $out/share/fonts/truetype/"$font"
      done

      runHook postInstall
    '';

    meta = {
      description = "The new system font for Windows";
      homepage = "https://learn.microsoft.com/en-us/windows/apps/design/downloads/#fonts";
      license = lib.licenses.unfree; # Guessing, haven't read what EULA allows
      maintainers = [];
      platforms = lib.platforms.all;
    };
  })
    #vesktop
    imagemagick

    (symlinkJoin {
      name = "my-discord";

      paths = [
        vesktop
      ];   

      postBuild = ''
        for size in 32 64 128 256 512 1024; do
          dim="$size"x"$size"
          rm $out/share/icons/hicolor/"$dim"/apps/vesktop.png
          ${lib.getExe imagemagick} ${../misc/discord.png} -resize "$dim" $out/share/icons/hicolor/"$dim"/apps/vesktop.png
        done

        rm $out/share/applications/vesktop.desktop
        cp ${../misc/discord.desktop} $out/share/applications/vesktop.desktop
      '';
    })

    spotify
    vlc

    fd
    
    wl-clipboard
    wofi
    xsel



    prismlauncher

   # graalvm-ce

    steam
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];


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
