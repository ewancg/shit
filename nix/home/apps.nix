# home/apps.nix; home config for apps (specific to the NixOS user, because work/personal rift

{ pkgs, util, ... }:
with pkgs;
let
  my-discord = (
    symlinkJoin {
      name = "my-discord";
      paths = [ vesktop ];
      postBuild = ''
        name="vesktop.png"
        for size in 32 64 128 256 512 1024; do
          dim="$size"x"$size"
          icondir="$out/share/icons/hicolor/$dim/apps"
          iconpath="$icondir/$name"
          mkdir -p "$icondir"
          [ -f "$iconpath" ] && rm "$iconpath"
          ${lib.getExe imagemagick} "${../misc/discord.png}" -resize "$dim" "$iconpath"
        done
        desktoppath="$out/share/applications/vesktop.desktop"
        [ -f "$desktoppath" ] && rm "$desktoppath"
        cp "${../misc/discord.desktop}" "$desktoppath"
      '';
    }
  );

  # my-ts3client = let webengine = pkgs.libsForQt5.qt5.qtwebengine; ts3 = pkgs.teamspeak3.override {
  #   libsForQt5 = (lib.updateManyAttrsByPath [
  #                 {
  #                   path = webengine;
  #                   update = old:
  #                     lib.filterAttrs (n: v: n != webengine) old;
  #                  }
  #                ] pkgs.libsForQt5);
  # }; in (
  #   symlinkJoin {
  #     name = "my-ts3client";
  #     paths = [
  #       ts3
  #     ];
  #     buildInputs = [
  #       makeWrapper
  #       pkgs.libsForQt5.qt5.qtwayland
  #       egl-wayland
  #     ];
  #     postBuild = ''
  #       wrapProgram $out/bin/ts3client \
  #         --add-flags "-platform wayland" \
  #         --set QT_WAYLAND_CLIENT_BUFFER_INTEGRATION " "
  #     '';
  #   }
  # );

  my-prismlauncher = (
    prismlauncher.override {
      jdks = util.jdks;
    }
  );

  # for Wayland
  my-vlc = (
    symlinkJoin {
      name = "my-vlc";
      paths = [ vlc ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/vlc \
          --unset DISPLAY
      '';
    }
  );

  my-minecraft-glfw = callPackage ../misc/minecraft-glfw/default.nix {
    withMinecraftPatch = true;
  };

  # qtcreator-fhs = (
  #   pkgs.buildFHSEnv {
  #     name = "qtcreator-fhs";
  #       targetPkgs =
  #       pkgs:
  #       (with pkgs; [
  #         qtcreator
  #         cmake
  #         stdenv.cc
  #         qt5.qtbase.bin
  #         qt5.qtbase.dev
  #         qt5.qttools.bin
  #         qt5.qttools.dev
  #         qt5.qmake
  #         gdb
  #       ]);
  #       runScript = pkgs.lib.getExe pkgs.qtcreator;
  #   }
  # );
in
{
  # VLC plugin path
  home.packages = with pkgs; [
    # Communication
    # my-discord
    equicord
    # ripcord
    # my-ts3client
    telegram-desktop
    #teamspeak_client

    # Games
    taterclient-ddnet
    ares
    dolphin-emu
    fceux
    my-prismlauncher
    my-minecraft-glfw
    #openrct2
    rusty-path-of-building
    rpcs3

    # Multimedia
    spot
    psst
    strawberry
    nicotine-plus
    spotifyd
    transmission_4-qt6
    my-vlc

    reaper
    bitwig-studio
    guitarix
    ptcollab
    vmpk

    # Productivity, misc.
    protonvpn-gui
    protonmail-bridge
    protonmail-desktop

    zed-editor
    dbeaver-bin
    cutter
    pkgs.cutterPlugins.rz-ghidra

    gnome-boxes

    alacritty

    sysprof
    btop


    qdirstat
  ];

  # xdg.configFile = {
  #   "QtProject/qtcreator" = {
  #     recursive = true;
  #     source = ../../dot/config/qtcreator;
  #   };
  #   #"QtProject/qtcreator/styles".source = ../../dot/config/qtcreator/styles;
  #   #"QtProject/qtcreator/themes".source = ../../dot/config/qtcreator/themes;
  #   #"QtProject/qtcreator/.clang-format".source = ../../dot/.clang-format;
  # };
}
