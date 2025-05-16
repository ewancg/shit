# home/apps.nix; home config for apps (specific to the NixOS user, because work/personal rift

{ pkgs, ... }:
with pkgs;
let
  # graal-pkgs = import (builtins.fetchTarball {
  #       sha256 = "1l2hq1n1jl2l64fdcpq3jrfphaz10sd1cpsax3xdya0xgsncgcsi";
  #       url = "https://github.com/NixOS/nixpkgs/archive/9957cd48326fe8dbd52fdc50dd2502307f188b0d.tar.gz";
  #   }) {};
  graalvm-ce = pkgs.graalvm-ce;

  vlc-plugin-pipewire = callPackage ../misc/vlc-plugin-pipewire/default.nix { };

  # for Wayland
  my-vlc = (symlinkJoin {
    name = "my-vlc";
    paths = [ vlc ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vlc \
        --unset DISPLAY
    '';
  });

  my-discord = (symlinkJoin {
    name = "my-discord";
    paths = [ vesktop ];
    postBuild = ''
      for size in 32 64 128 256 512 1024; do
        dim="$size"x"$size"
        rm $out/share/icons/hicolor/"$dim"/apps/vesktop.png
        ${lib.getExe imagemagick} ${../misc/discord.png} -resize "$dim" $out/share/icons/hicolor/"$dim"/apps/vesktop.png
      done
      rm $out/share/applications/vesktop.desktop
      cp ${../misc/discord.desktop} $out/share/applications/vesktop.desktop
    '';
  });

  # Ugly hack. Not needed anymore
  # my-ts3client = (symlinkJoin {
  #   name = "my-ts3client";
  #   paths = [ teamspeak_client ];
  #   buildInputs = [ makeWrapper ];
  #   postBuild = ''
  #     wrapProgram $out/bin/ts3client \
  #       --set QT_SCALE_FACTOR "1.5"
  #   '';
  # });

  my-prismlauncher = (prismlauncher.override {
    # deprecated https://github.com/NixOS/nixpkgs/commit/2a5017a5550a32dfdf4000bd8fa2fea89e6a0f95
    #  withWaylandGLFW = true;
    jdks = [
      graalvm-ce
      temurin-bin-21
      temurin-bin-8
      temurin-bin-17
    ];
  });
  my-minecraft-glfw = callPackage ../misc/minecraft-glfw/default.nix {
    withMinecraftPatch = true;
  };

  my-obs = (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
    ];
  });

  qtcreator-fhs = (pkgs.buildFHSEnv {
    name = "qtcreator-fhs";

    targetPkgs = pkgs: (with pkgs; [
      qtcreator
      cmake
      stdenv.cc
      qt5.qtbase.bin
      qt5.qtbase.dev
      qt5.qttools.bin
      qt5.qttools.dev
      qt5.qmake
      gdb
    ]);

    runScript = pkgs.lib.getExe pkgs.qtcreator;
  });
in
{
  # VLC plugin path
  home.packages = with pkgs; [
    # Communication
    my-discord
    ripcord
    #my-ts3client
    teamspeak_client
    thunderbird
    teams-for-linux
    slack

    # Games
    taterclient-ddnet
    ares
    dolphin-emu
    snes9x-gtk
    fceux
    my-prismlauncher
    my-minecraft-glfw
    openrct2
    path-of-building
    rpcs3
    steam

    # Multimedia
    mpv
    my-vlc
    spotify
    spot
    psst
    strawberry
    vlc-plugin-pipewire
    okular
    photoflare

    easyeffects
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

    gnome-boxes

    alacritty

    sysprof

    qdirstat

    # Java
    # graal-pkgs
  ];

  xdg.configFile = {
    "QtProject/qtcreator" = {
      recursive = true;
      source = ../../dot/config/qtcreator;
    };
    "QtProject/qtcreator/styles".source = ../../dot/config/qtcreator/styles;
    "QtProject/qtcreator/themes".source = ../../dot/config/qtcreator/themes;
    #"QtProject/qtcreator/.clang-format".source = ../../dot/.clang-format;
  };

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ firefox pkg-config ]);
  };
}
