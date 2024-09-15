{ pkgs, ... }:
with pkgs;
let
  segoe-ui-variable-fonts = (callPackage ./misc/segoe-ui-variable/default.nix { });
  vlc-plugin-pipewire = callPackage ./misc/vlc-plugin-pipewire/default.nix { };
  
  # for Wayland
  my-vlc = ( symlinkJoin {
    name = "my-vlc";
    paths = [ vlc ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vlc \
        --unset DISPLAY
    '';
  });

  my-discord = ( symlinkJoin {
    name = "my-discord";
    paths = [ vesktop ];
    postBuild = ''
      for size in 32 64 128 256 512 1024; do
        dim="$size"x"$size"
        rm $out/share/icons/hicolor/"$dim"/apps/vesktop.png
        ${lib.getExe imagemagick} ${./misc/discord.png} -resize "$dim" $out/share/icons/hicolor/"$dim"/apps/vesktop.png
      done
      rm $out/share/applications/vesktop.desktop
      cp ${./misc/discord.desktop} $out/share/applications/vesktop.desktop
    '';
  });

  # Ugly hack. Not needed anymore
  # my-ts3client = ( symlinkJoin {
  #   name = "my-ts3client";
  #   paths = [ teamspeak_client ];
  #   buildInputs = [ makeWrapper ];
  #   postBuild = ''
  #     wrapProgram $out/bin/ts3client \
  #       --set QT_SCALE_FACTOR "1.5"
  #   '';
  # });

  my-prismlauncher = ( prismlauncher.override {
    withWaylandGLFW = true;
    jdks = [
      temurin-bin-21
      temurin-bin-8
      temurin-bin-17
    ];
  });

  my-obs = ( pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
    ];
  });


  # System packages
  system = [
    # cli tools
    at
    bc
    choose
    datamash
    fastfetch
    ffmpeg
    file
    gojq
    grim
    kde-cli-tools
    killall
    libnotify
    p7zip
    patchelf
    playerctl
    slurp
    traceroute
    unzip

    # system
    avahi-compat
    bind
    binutils
    btrfs-progs
    fuse
    gamescope
    glibcLocales
    mkinitcpio-nfs-utils
    nfs-utils
    nix-ld
    sshfs-fuse
    udisks
    v4l-utils

    # Nix
    nil
    nix-index
    nixpkgs-fmt

    # Essential libraries and utilities
    dhcpcd
    git
    gnupg
    lshw
    openssl
    pciutils
    udisks
    wget

    # Wine
    vkd3d-proton
    wine-wayland
    wine64
    winetricks
    wineWowPackages.stable
    wineWowPackages.waylandFull

    # Other
    headsetcontrol
    openrgb
  ];

  # Packages involved/integrated in my terminal workflow
  termish = with pkgs; [
    alacritty
    fish
    fishPlugins.bass
    tmux

    fd
    fzf
    tree

    neovim

    imagemagick

    # system wide rust... one day
    # (callPackage ../misc/rustup.nix {})
  ];

  dev = with pkgs; [
    # dev tools (rare)
    ida-free
    python3
    qtcreator
    rustup
  ];

  # Apps (move to home.nix?)
  apps = with pkgs; [
    # Communication
    my-discord
    teamspeak_client
    thunderbird

    # System monitors
    gnome-disk-utility
    gnome-system-monitor
    mission-center
    nvidia-system-monitor-qt
    nvtopPackages.full

    # Games
    ddnet
    dolphin-emu
    fceux
    my-prismlauncher
    openrct2
    path-of-building
    rpcs3
    steam

    # Multimedia
    my-vlc
    spotify
    strawberry
    vlc-plugin-pipewire

    alsa-scarlett-gui
    headsetcontrol
    pwvucontrol
    qpwgraph

    nicotine-plus    
    spotifyd
    transmission_4
    transmission-remote-gtk

    bitwig-studio
    guitarix
    ptcollab
    vmpk

    my-obs
    normcap # OCR

    # Productivity, misc.
    protonvpn-gui
    zerotierone

    blueman
    firefox
    fsearch
    gimp
    nautilus
    obsidian
    sticky
    ungoogled-chromium
    
    gnome-calculator
    gnome-font-viewer
    gnome.gnome-boxes
  ];
in
{
  # Fonts
  fonts.packages = with pkgs; [
    # Windows fonts
    segoe-ui-variable-fonts
    wine64Packages.fonts
    winePackages.fonts
    wineWow64Packages.fonts
    wineWowPackages.fonts

    # Not Windows fonts
    cantarell-fonts
    corefonts
    dina-font
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    noto-fonts
    open-sans
    proggyfonts
    ubuntu_font_family
    ucs-fonts
    vistafonts
    zilla-slab
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

  # For broken package "nose" (which is used for Logitech hardware support)
  nixpkgs.overlays = [
    (_: prev: {
        python312 = prev.python312.override { packageOverrides = _: pysuper: { nose = pysuper.pynose; }; };
    })
  ];

  # VLC plugin path
  environment.variables.VLC_PLUGIN_PATH = "${vlc-plugin-pipewire}/lib";

  # Other
  environment.systemPackages = [] ++ system ++ termish ++ dev ++ apps;
}
