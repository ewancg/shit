# home/apps.nix; home config for apps (specific to the NixOS user, because work/personal rift

{ config, pkgs, util, hostname, secrets, ... }:
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
      jdks = util.opt.jdks;
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
  # programs.nixcord = {
  #   discord = {
  #     equicord.enable = true;
  #   };
  #   vesktop.enable = true;
  #   equibop.enable = true;
  #   quickCss = let s = builtins.trace config.lib.stylix config.lib.stylix; in ''
  #     /**
  #      * @name system24
  #      * @description a tui-style discord theme.
  #      * @author refact0r
  #      * @version 2.0.0
  #      * @invite nz87hXyvcy
  #      * @website https://github.com/refact0r/system24
  #      * @source https://github.com/refact0r/system24/blob/master/theme/system24.theme.css
  #      * @authorId 508863359777505290
  #      * @authorLink https://www.refact0r.dev
  #     */
  #
  #     /* import theme modules */
  #     @import url('https://refact0r.github.io/system24/build/system24.css');
  #
  #     body {
  #         text-rendering: optimizeLegibility !important;
  #         --font: \'\';
  #         --code-font: 'DM Mono';
  #         font-weight: 300; /* text font weight. 300 is light, 400 is normal. DOES NOT AFFECT BOLD TEXT */
  #         letter-spacing: -0.06ch; /* decreases letter spacing for better readability. recommended on monospace fonts.*/
  #
  #         /* sizes */
  #         --gap: 0.33em; /* spacing between panels */
  #         --divider-thickness: 0.11em; /* thickness of unread messages divider and highlighted message borders */
  #         --border-thickness: 0.11em; /* thickness of borders around main panels. DOES NOT AFFECT OTHER BORDERS */
  #         --border-hover-transition: 0.05s ease; /* transition for borders when hovered */
  #
  #         /* animation/transition options */
  #         --animations: on; /* off: disable animations/transitions, on: enable animations/transitions */
  #         --list-item-transition: 0.05s ease; /* transition for list items */
  #         --dms-icon-svg-transition: 0.05s ease; /* transition for the dms icon */
  #
  #         /* top bar options */
  #         --top-bar-height: var(--gap); /* height of the top bar (discord default is 36px, old discord style is 24px, var(--gap) recommended if button position is set to titlebar) */
  #         --top-bar-button-position: titlebar; /* off: default position, hide: hide buttons completely, serverlist: move inbox button to server list, titlebar: move inbox button to channel titlebar (will hide title) */
  #         --top-bar-title-position: off; /* off: default centered position, hide: hide title completely, left: left align title (like old discord) */
  #         --subtle-top-bar-title: off; /* off: default, on: hide the icon and use subtle text color (like old discord) */
  #
  #         /* window controls */
  #         --custom-window-controls: off; /* off: default window controls, on: custom window controls */
  #         --window-control-size: 14px; /* size of custom window controls */
  #
  #         /* dms button options */
  #         --custom-dms-icon: off; /* off: use default discord icon, hide: remove icon entirely, custom: use custom icon */
  #         --dms-icon-svg-url: url(\'\'); /* icon svg url. MUST BE A SVG. */
  #         --dms-icon-svg-size: 90%; /* size of the svg (css mask-size property) */
  #         --dms-icon-color-before: var(--icon-subtle); /* normal icon color */
  #         --dms-icon-color-after: var(--white); /* icon color when button is hovered/selected */
  #         --custom-dms-background: off; /* off to disable, image to use a background image (must set url variable below), color to use a custom color/gradient */
  #         --dms-background-image-url: url(\'\'); /* url of the background image */
  #         --dms-background-image-size: cover; /* size of the background image (css background-size property) */
  #         --dms-background-color: linear-gradient(70deg, var(--blue-2), var(--purple-2), var(--red-2)); /* fixed color/gradient (css background property) */
  #
  #         /* background image options */
  #         --background-image: off; /* off: no background image, on: enable background image (must set url variable below) */
  #         --background-image-url: url(\'\'); /* url of the background image */
  #
  #         /* transparency/blur options */
  #         /* NOTE: TO USE TRANSPARENCY/BLUR, YOU MUST HAVE TRANSPARENT BG COLORS. FOR EXAMPLE: --bg-4: hsla(220, 15%, 10%, 0.7); */
  #         --transparency-tweaks: on; /* off: no changes, on: remove some elements for better transparency */
  #         --remove-bg-layer: on; /* off: no changes, on: remove the base --bg-3 layer for use with window transparency (WILL OVERRIDE BACKGROUND IMAGE) */
  #         --panel-blur: on; /* off: no changes, on: blur the background of panels */
  #         --blur-amount: 36px; /* amount of blur */
  #         --bg-floating: #282624; /* set this to a more opaque color if floating panels look too transparent. only applies if panel blur is on  */
  #
  #         /* other options */
  #         --small-user-panel: off; /* off: default user panel, on: smaller user panel like in old discord */
  #
  #         /* unrounding options */
  #         --unrounding: off; /* off: default, on: remove rounded corners from panels */
  #
  #         /* styling options */
  #         --custom-spotify-bar: on; /* off: default, on: custom text-like spotify progress bar */
  #         --ascii-titles: on; /* off: default, on: use ascii font for titles at the start of a channel */
  #         --ascii-loader: system24; /* off: default, system24: use system24 ascii loader, cats: use cats loader */
  #
  #         /* panel labels */
  #         --panel-labels: off; /* off: default, on: add labels to panels */
  #         --label-color: var(--text-muted); /* color of labels */
  #         --label-font-weight: 500; /* font weight of labels */
  #
  #         background-color: #d5c4a11a !important;
  #     }
  #
  #     #app-mount > div > div > div > div > div > div > div > div > div > div > section > div > div > div > div > div > div > div[class*="labelWrapper"] {
  #         margin-top: 0.5em;
  #     }
  #
  #     /* color options */
  #     :root {
  #         --colors: on; /* off: discord default colors, on: midnight custom colors */
  #
  #         /* text colors */
  #         --text-0: #282624; /* text on colored elements */
  #         --text-1: #fbf1c7; /* other normally white text */
  #         --text-2: #ebdbb2; /* headings and important text */
  #         --text-3: #d5c4a1; /* normal text */
  #         --text-4: hsl(39, 24%, 44%); /* icon buttons and channels */
  #         --text-5: hsl(39, 23%, 44%); /* muted channels/chats and timestamps */
  #
  #         /* background and dark colors */
  #         --bg-1: hsla(30, 9%, 29%, 1);; /* dark buttons when clicked */
  #         --bg-2: hsl(30, 9%, 25%); /* dark buttons */
  #         --bg-3: hsla(30, 8%, 22%, 0.88); /* spacing, secondary elements */
  #         --bg-4: hsla(30, 7%, 15%, 0.88); /* main background color */
  #         --hover: #fbf1c711; /* channels and buttons when hovered */
  #         --active: #ebdbb211; /* channels and buttons when clicked or selected */
  #         --active-2: #d5c4a111; /* extra state for transparent buttons */
  #         --message-hover: #665c541a; /* messages when hovered */
  #
  #         /* accent colors */
  #         --accent-1: var(--blue-1); /* links and other accent text */
  #         --accent-2: var(--blue-2); /* small accent elements */
  #         --accent-3: var(--blue-3); /* accent buttons */
  #         --accent-4: var(--blue-4); /* accent buttons when hovered */
  #         --accent-5: var(--blue-5); /* accent buttons when clicked */
  #         --accent-new: var(--accent-2); /* stuff that's normally red like mute/deafen buttons */
  #         --mention: linear-gradient(to right, color-mix(in hsl, var(--accent-2), transparent 90%) 40%, transparent); /* background of messages that mention you */
  #         --mention-hover: linear-gradient(to right, color-mix(in hsl, var(--accent-2), transparent 95%) 40%, transparent); /* background of messages that mention you when hovered */
  #         --reply: linear-gradient(to right, color-mix(in hsl, var(--text-3), transparent 90%) 40%, transparent); /* background of messages that reply to you */
  #         --reply-hover: linear-gradient(to right, color-mix(in hsl, var(--text-3), transparent 95%) 40%, transparent); /* background of messages that reply to you when hovered */
  #
  #         /* status indicator colors */
  #         --online: var(--green-2); /* change to #43a25a for default */
  #         --dnd: var(--red-2); /* change to #d83a42 for default */
  #         --idle: var(--yellow-2); /* change to #ca9654 for default */
  #         --streaming: var(--purple-2); /* change to #593695  for default */
  #         --offline: var(--text-4); /* change to #83838b for default offline color */
  #
  #         /* border colors */
  #         --border-light: hsla(39, 23%, 44%, 0.25); /* general light border color */
  #         --border: hsla(39, 24%, 44%, 0.366); /* general normal border color */
  #         --border-hover: var(--accent-2); /* border color of panels when hovered */
  #         --button-border: hsla(30, 8%, 22%, 0.8); /* neutral border color of buttons */
  #
  #         /* base colors */
  #         --red-1: hsla(6, 96%, 59%, 0.85);
  #         --red-2: hsla(6, 96%, 66%, 0.85);
  #         --red-3: hsla(6, 96%, 72%, 0.65);
  #         --red-4: hsla(6, 96%, 80%, 0.65);
  #         --red-5: hsla(6, 96%, 88%, 0.65);
  #
  #         --green-1: hsla(61, 66%, 44%, 0.85);
  #         --green-2: hsla(61, 69%, 55%, 0.85);
  #         --green-3: hsla(61, 72%, 66%, 0.65);
  #         --green-4: hsla(61, 75%, 77%, 0.65);
  #         --green-5: hsla(61, 78%, 88%, 0.65);
  #
  #         --blue-1: hsla(157, 16%, 58%, 0.85);
  #         --blue-2: hsla(157, 19%, 66%, 0.85);
  #         --blue-3: hsla(157, 21%, 72%, 0.65);
  #         --blue-4: hsla(157, 24%, 80%, 0.65);
  #         --blue-5: hsla(157, 27%, 88%, 0.65);
  #
  #         --yellow-1: hsla(42, 95%, 58%, 0.85);
  #         --yellow-2: hsla(42, 95%, 66%, 0.85);
  #         --yellow-3: hsla(42, 95%, 72%, 0.65);
  #         --yellow-4: hsla(42, 95%, 80%, 0.65);
  #         --yellow-5: hsla(42, 95%, 88%, 0.65);
  #
  #         --purple-1: hsla(344, 47%, 68%, 0.85);
  #         --purple-2: hsla(344, 50%, 73%, 0.85);
  #         --purple-3: hsla(344, 53%, 78%, 0.65);
  #         --purple-4: hsla(344, 56%, 83%, 0.65);
  #         --purple-5: hsla(344, 59%, 88%, 0.65);
  #     }
  #   '';
  #   config = {
  #     useQuickCss = true;
  #     #themeLinks = [
  #     #];
  #     frameless = true;
  #     plugins = {
  #       allCallTimers.enable = true;
  #       betterQuickReact.enable = true;
  #       betterSettings.enable = true;
  #       biggerStreamPreview.enable = true;
  #       BlurNSFW.enable = true;
  #       callTimer.enable = true;
  #       colorSighted.enable = true;
  #       crashHandler.enable = true;
  #       fakeNitro.enable = true;
  #       fakeProfileThemes.enable = true;
  #       fixCodeblockGap.enable = true;
  #       fixImagesQuality.enable = true;
  #       fixSpotifyEmbeds.enable = true;
  #       fixYoutubeEmbeds.enable = true;
  #       gameActivityToggle.enable = true;
  #       iLoveSpam.enable = true;
  #       imageFilename.enable = true;
  #       imageLink.enable = true;
  #       keepCurrentChannel.enable = true;
  #       messageClickActions.enable = true;
  #       messageLatency.enable = true;
  #       MutualGroupDMs.enable = true;
  #       noF1.enable = true;
  #       noMosaic.enable = true;
  #       noOnboardingDelay.enable = true;
  #       noPendingCount.enable = true;
  #       noTypingAnimation.enable = true;
  #       quickMention.enable = true;
  #       relationshipNotifier.enable = true;
  #       reverseImageSearch.enable = true;
  #       sendTimestamps.enable = true;
  #       showHiddenChannels.enable = true;
  #       showHiddenThings.enable = true;
  #       spotifyCrack.enable = true;
  #       translate.enable = true;
  #       validReply.enable = true;
  #       validUser.enable = true;
  #       voiceMessages.enable = true;
  #       volumeBooster.enable = true;
  #       webKeybinds.enable = true;
  #       webScreenShareFixes.enable = true;
  #       youtubeAdblock.enable = true;
  #     };
  #   };
  # };

  # VLC plugin path
  home.packages = with pkgs; [
    # Communication
    # my-discord
    (discord.override {
      withEquicord = true;
    })

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

  services.tailscale-systray.enable = secrets.s.${hostname}.tailscale.enable;


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
