{ pkgs, config, ... }:
with pkgs;
let
  vlc-plugin-pipewire = callPackage ./misc/vlc-plugin-pipewire/default.nix { };
  # System packages
  system = [
    # Nix
    nix-index
    nixpkgs-fmt
    nil

    # Essential libraries and utilities
    openssl
    gnupg
    wget
    git
    lshw
    pciutils
    udisks

    # Wine
    wine64
    winetricks
    #    wineWowPackages.staging
    wineWowPackages.stable
    wineWowPackages.waylandFull

    wine-wayland
    vkd3d-proton

    # Other
    openrgb
    # solaar # broken on 7 21 24
    logiops
    headsetcontrol
  ];

  # Packages involved/integrated in my terminal workflow
  termish = with pkgs; [
    alacritty
    tmux
    fish
    fishPlugins.bass

    fd
    fzf

    neovim

    imagemagick

    # system wide rust... one day
    # (callPackage ../misc/rustup.nix {})
  ];

  # Apps (move to home.nix?)
  apps = with pkgs; [
    # Communication
    (symlinkJoin {
      name = "my-discord";

      paths = [
        vesktop
      ];

      postBuild = ''
        for size in 32 64 128 256 512 1024; do
          dim="$size"x"$size"
          rm $out/share/icons/hicolor/"$dim"/apps/vesktop.png
          ${lib.getExe imagemagick} ${./misc/discord.png} -resize "$dim" $out/share/icons/hicolor/"$dim"/apps/vesktop.png
        done

        rm $out/share/applications/vesktop.desktop
        cp ${./misc/discord.desktop} $out/share/applications/vesktop.desktop
      '';
    })
    (symlinkJoin {
      name = "my-ts3client";
      paths = [ teamspeak_client ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ts3client \
          --set QT_SCALE_FACTOR "1.5"
      '';
    })
    # teamspeak_client

    # "Task manager"
    mission-center

    # Gaming
    (prismlauncher.override {
      withWaylandGLFW = true;
      jdks = [
        temurin-bin-21
        temurin-bin-8
        temurin-bin-17
      ];
    })
    steam
    # Multimedia

    # for Wayland
    (symlinkJoin {
      name = "my-vlc";
      paths = [ vlc ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/vlc \
          --unset DISPLAY
      '';
    })
    vlc-plugin-pipewire

    gimp

    # Productivity, misc.
    qpwgraph
    pwvucontrol
    obsidian

    fsearch
    nautilus
    gnome-disk-utility
  ];
in
{
  # programs.spicetify =
  #    let
  #      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  #    in import (<nixpkgs/nixos/lib/eval-config.nix>)
  #    {
  #      enable = true;
  #      enabledExtensions = with spicePkgs.extensions; [
  #        #adblock
  #        hidePodcasts
  #        #shuffle # shuffle+ (special characters are sanitized out of extension names)
  #      ];
  #      theme = spicePkgs.themes.catppuccin;
  #      colorScheme = "mocha";
  #    };

  # Fonts
  fonts.packages = with pkgs; [
    (callPackage ./misc/segoe-ui-variable/default.nix { })
    wineWowPackages.fonts
    wineWow64Packages.fonts
    winePackages.fonts
    wine64Packages.fonts

    cantarell-fonts
    ubuntu_font_family
    noto-fonts
    open-sans
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    zilla-slab
    ucs-fonts
    corefonts
    vistafonts
    font-awesome
  ];

  # Run non-Nix binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;

  # File manager
  programs.thunar.enable = true;

  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  programs.xfconf.enable = true; # Required for Thunar to save its config
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for image

  # Disks
  programs.gnome-disks.enable = true;
  services.udisks2.enable = true;

  # for nix-index command not found integration
  programs.command-not-found.enable = false;

  # VLC plugin path
  environment.variables.VLC_PLUGIN_PATH = "${vlc-plugin-pipewire}/lib";

  # Other
  environment.systemPackages = with pkgs; [
    normcap
  ] ++ system ++ termish ++ apps;
}
