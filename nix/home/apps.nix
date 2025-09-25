# home/apps.nix; home config for apps (specific to the NixOS user, because work/personal rift

{ pkgs, util, ... }:
with pkgs;
let
  my-discord = (
    symlinkJoin {
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
    }
  );

  my-ts3client = (
    symlinkJoin {
      name = "my-ts3client";
      paths = [ teamspeak_client ];
      buildInputs = [
        makeWrapper
        pkgs.libsForQt5.qt5.qtwayland
      ];
      postBuild = ''
        wrapProgram $out/bin/ts3client \
          --add-flags "-platform wayland" \
          --set QT_WAYLAND_CLIENT_BUFFER_INTEGRATION "wayland-xcomposite-egl"
      '';
    }
  );

  my-prismlauncher = (
    prismlauncher.override {
      jdks = util.jdks;
    }
  );

  # for Wayland
  # my-vlc = (
  #   symlinkJoin {
  #     name = "my-vlc";
  #     paths = [ vlc ];
  #     buildInputs = [ makeWrapper ];
  #     postBuild = ''
  #       wrapProgram $out/bin/vlc \
  #         --unset DISPLAY
  #     '';
  #   }
  # );

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
    my-discord
    ripcord
    my-ts3client
    #teamspeak_client

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

    # Multimedia
    spot
    psst
    strawberry
    nicotine-plus
    spotifyd
    transmission_4
    transmission-remote-gtk

    bitwig-studio
    guitarix
    ptcollab
    vmpk

    # Productivity, misc.
    protonvpn-gui
    protonmail-bridge
    protonmail-desktop

    dbeaver-bin

    gnome-boxes

    alacritty

    sysprof

    qdirstat

    zed-editor
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
