{
  config,
  pkgs,
  util,
  ...
}:
let
  col = config.lib.stylix.colors;
  mediaDir = "${config.home.homeDirectory}/media";
  samsungLF32TU87 = {
    desc = "Samsung Electric Company LF32TU87 HCPRA08903";
    mode = "903.40 3840 4168 4592 5344 2160 2161 2164 2254 +hsync -vsync";
    pos = "0x0";
    scale = "1.33";
    bitdepth = "8";
  };
  xymMNN = {
    desc = "XYM MNN 0x00000055";
    mode = "921.87 2560 2792 3080 3600 1600 1601 1604 1742 +hsync -vsync";
    pos = "auto-center-down";
    scale = "1.33";
    bitdepth = "10";
  };
  _acerB326HK = {
    desc = "Acer Technologies B326HK T1NAA0038522";
    mode = "903.40 3840 4168 4592 5344 2160 2161 2164 2254 -hsync -vsync";
    pos = "auto-right";
    scale = "1.33";
    bitdepth = "8";
  };
  m1 = samsungLF32TU87;
  m2 = xymMNN;
  # m2 = _acerB326HK;hy
in
{
  home.sessionVariables = {
    # XWayland scaling is disabled
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    #HYPRCURSOR_SIZE = "192";

    # Wayland
    SDL_VIDEODRIVER = "wayland,x11,windows";
    SDL2_VIDEO_DRIVER = "wayland,x11,windows";
    GDK_BACKEND = "wayland,x11,*";

    CLUTTER_BACKEND = "wayland";

    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_QPA_PLATFORM = "wayland;xcb";

    MOZ_ENABLE_WAYLAND = 1;
    _JAVA_AWT_WM_NONREPARENTING = 1;

    __GL_MaxFramesAllowed = 0;

    # Wayland
    XDG_SESSION_TYPE = "wayland";
    # https://www.reddit.com/r/linux_gaming/comments/1cvrvyg/psa_easy_anticheat_eac_failed_to_initialize/

    NIXOS_OZONE_WL = "1";

    # Hyprland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Qt
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    # QT_STYLE_OVERRIDE = "qt5ct-style";

    GTK_THEME = "adw-gtk3";
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      xwayland.force_zero_scaling = true;
      cursor.no_hardware_cursors = false;

      general = {
        gaps_in = 2;
        gaps_out = 4;

        border_size = 2;

        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        "col.active_border" = "rgb(${col.base0D})";
        "col.inactive_border" = "rgb(${col.base02})";
        "col.nogroup_border" = "rgb(${col.base02})";
        "col.nogroup_border_active" = "rgb(${col.base04})";

        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true;

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = true;

        layout = "dwindle";

      };

      group = {
        insert_after_current = false;

        "col.border_active" = "rgba(${col.base0D}bb)";
        "col.border_inactive" = "rgba(${col.base03}bb)";
        "col.border_locked_active" = "rgba(${col.base0B}bb)";
        "col.border_locked_inactive" = "rgba(${col.base03}bb)";

        groupbar = {
          "col.active" = "rgba(${col.base01}dd)";
          "col.inactive" = "rgba(${col.base00}dd)";
          "col.locked_active" = "rgba(${col.base09}dd)";
          "col.locked_inactive" = "rgba(${col.base00}dd)";

          height = 24;
          keep_upper_gap = false;
          render_titles = true;
          gradients = true;

          # round_only_edges = true
          gradient_round_only_edges = true;
          gradient_rounding = 10;
          gradient_rounding_power = 2.5;

          font_family = "San Francisco Text";
          font_size = 14;
          text_color = "rgb(${col.base07})";
          text_color_inactive = "rgb(${col.base05})";
          font_weight_active = "semibold";
          font_weight_inactive = "medium";

          indicator_height = 0;
          # # this just pushes it in on either side to avoid looking awkward next to the rounder gradients
          # rounding = 6;
          # rounding_power = 0;
          # indicator_height = 2;
          # indicator_gap = 1;

          gaps_in = 2;
          gaps_out = 2;
        };

      };

      decoration = {
        rounding = 6;

        active_opacity = 1.0;
        inactive_opacity = 0.66;

        shadow = {
          enabled = true;

          range = 18;
          render_power = 5;
          scale = 0.5;

          "color" = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 16;
          passes = 2;
          ignore_opacity = true;
          vibrancy = 0.4696;
          vibrancy_darkness = 0.75;
          noise = 0.0625;
          brightness = 0.35;
          contrast = 0.65;
          special = true;
        };
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.25, 0.9, 0.1, 1.0";

        animation = [
          "windows, 1, 2.5, myBezier"
          "windowsOut, 1, 5, default, popin 80%"
          "border, 1, 10, myBezier"
          "borderangle, 1, 8, default"
          "fade, 1, 3, myBezier"
          "workspaces, 1, 6, myBezier"
        ];
      };

      windowrulev2 = [
        "immediate, match:focus true"
        "immediate, match:workspace w[t1]"
        "border_size 0, match:float false, match:workspace w[t1]"
        "rounding 0, match:float false, match:workspace w[t1]"
        "border_size 0, match:float false, match:workspace f[1]"
        "rounding 0, match:float false, match:workspace f[1]"

        "border_size 0, match:workspace f[1]"

        "no_screen_share on, match:class telegram"
        "no_screen_share off, match:class vesktop"
        "no_screen_share on, match:class ts3client"
        "no_screen_share on, match:class thunderbird"

        "suppressevent maximize, match:class:.*" # You'll probably like this.
        "border_color rgba(${col.base0D}bb), match:float true" # Blue
        "border_color rgba(${col.base0B}ff), match:title ^(Spotify Premium)" # Green
        "border_color rgba(${col.base0B}bb), match:title ^(Spotify Premium), match:float true" # Green
        "border_color rgba(${col.base0B}ff), match:class ^(dev.alextren.Spot)" # Green
        "border_color rgba(${col.base0B}bb), match:class ^(dev.alextren.Spot), match:float true" # Green
        "border_color rgba(${col.base0E}ff), match:class ^(obsidian|Alacritty)" # Purple
        "border_color rgba(${col.base0E}bb), match:class ^(obsidian|Alacritty), match:float true" # Purple
        "border_color rgba(${col.base0A}ff), match:xwayland true" # Yellow f9e2afff
        "border_color rgba(${col.base0A}bb), match:xwayland true, match:floating true" # Yellow f9e2afbb
        "border_color rgba(${col.base08}ff), match:fullscreen true" # Red

      ];

      dwindle = {
        smart_split = true;
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      opengl = {
        nvidia_anti_flicker = false;
      };

      render = {
        # explicit_sync = 1
        # explicit_sync_kms = 1
        direct_scanout = 1;
      };

      quirks = {
        prefer_hdr = 1;
      };

      misc = {
        disable_splash_rendering = true;
        enable_swallow = true;
        swallow_regex = "Alacritty";
        font_family = "Cantarell";
        disable_hyprland_logo = true;
        force_default_wallpaper = 2;
        # background_color = "0x2e3c54";
        vfr = false;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        vrr = false;
        focus_on_activate = true;
        allow_session_lock_restore = true;
        initial_workspace_tracking = 2;
        enable_anr_dialog = false;
      };

      input = {
        kb_layout = "us,us";
        kb_variant = ",colemak";

        # instead of bindl=$mod, space, exec, hyprctl switchxkblayout metadot---das-keyboard-das-keyboard next
        kb_options = [
          "grp:win_space_toggle"
          "fkeys:basic_13-24"
        ];
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad.natural_scroll = false;
      };

      device = [
        {
          name = "metadot---das-keyboard-das-keyboard";
          repeat_rate = 50;
          repeat_delay = 250;
        }
      ];

      "$mod" = "SUPER";
      "$terminal" = "${pkgs.alacritty}/bin/alacritty";
      "$fileManager" = "nautilus";
      "$fileSearch" = "fsearch";
      "$menu" = "wofi --show drun --hide-scroll true --width 640 --height 360 --allow-images true";

      bind = with util.commands; [
        # Black overlay for monitor (focus)
        "$mod SHIFT, B, exec,  ${util.script "eww-toggle-window"} overlay \"\" default"

        # Toggle mic mutes
        "$mod, F12, pass, class:^(ts3client|TeamSpeak 3)$"
        "$mod,Alt_R,sendshortcut,CTRL SHIFT,M,class:^(ts3client|TeamSpeak 3)"
        "$mod,Control_R,sendshortcut,CTRL SHIFT,M,class:vesktop"

        # Enforce window/workspace mappings
        "$mod SHIFT, R, exec, ${util.script "reset-window-positions"}"

        # Media controls
        ",XF86AudioRaiseVolume, exec, ${util.script "dunst-status-change"} volume up"
        ",XF86AudioLowerVolume, exec, ${util.script "dunst-status-change"} volume down"
        ",XF86AudioMute, exec, ${util.script "dunst-status-change"} volume mute"
        ",XF86AudioPlay, exec, ${playerctl} play-pause"
        ",XF86AudioNext, exec, ${playerctl} next"
        ",XF86AudioPrev, exec, ${playerctl} previous"

        # Color picker
        "$mod SHIFT, C, exec, hyprpicker -nra"

        # Screenshot
        "$mod SHIFT, S, exec, _SLURP_HIGHLIGHT=${col.base0D} ${util.script "capture-image"} area '${mediaDir}/screenshots'"
        "ALT, Print, exec,    ${util.script "capture-image"} active '${mediaDir}/window-screenshots'"
        ", Print, exec,       ${util.script "capture-image"} output '${mediaDir}/monitor-screenshots'"

        # Video capture
        "CTRL $mod SHIFT, S, exec, _SLURP_HIGHLIGHT=${col.base0E} ${util.script "capture-video"} region '${mediaDir}/recordings'"
        "CTRL ALT, Print, exec,    ${util.script "capture-video"} window:active '${mediaDir}/recordings'"
        "CTRL , Print, exec,       ${util.script "capture-video"} monitor:active '${mediaDir}/recordings'"

        # Text capture
        "$mod SHIFT, T, exec, _SLURP_HIGHLIGHT=${col.base0F} ${util.script "capture-text"} '${mediaDir}/ocr-screenshots'"

        # Upload newest media file
        ''$mod SHIFT, U, exec, ${util.script "upload-newest-media"} "${mediaDir}"''

        # Launchers
        "$mod, Q, exec, [float; size 873 427] $terminal"
        "$mod, R, exec, $menu"
        "$mod, F, exec, $fileManager"
        "$mod SHIFT, F, exec, $fileSearch"
        ", pause, exec, $fileSearch"

        # Exit hyprland
        "$mod CTRL, M, exit,"

        # Close window
        "$mod, C, killactive,"

        # Force close window
        ''$mod CTRL, C, exec, kill -9 "$(${hyprctl} -j activewindow | ${gojq} -r '.pid')"''

        # Tiling shortcuts
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, A, pin,"
        "$mod, J, togglesplit,"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, G, togglegroup"
        "$mod, L, lockactivegroup"

        # Workspace fullscreen
        "$mod SHIFT, up, fullscreen, 1"
        # Complete fullscreen (over bar)
        "$mod, F11, fullscreen, 0"
        # Fake fullscreen (app is tiled but behaves as if it was in fullscreen)
        "$mod ALT, F11, fullscreenstate, 0, 3,"

        # Special workspace
        "$mod, grave, togglespecialworkspace, magic"
        "$mod SHIFT, grave, movetoworkspace, special:magic"

        # Navigate across numbered workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod ALT, 1, workspace, 6"
        "$mod ALT, 2, workspace, 7"
        "$mod ALT, 3, workspace, 8"
        "$mod ALT, 4, workspace, 9"
        "$mod ALT, 5, workspace, 10"

        # Move window to numbered workspace
        "$mod, 1, moveworkspacetomonitor, 1  monitor:desc:${m1.desc}"
        "$mod, 2, moveworkspacetomonitor, 2  monitor:desc:${m1.desc}"
        "$mod, 3, moveworkspacetomonitor, 3  monitor:desc:${m1.desc}"
        "$mod, 4, moveworkspacetomonitor, 4  monitor:desc:${m1.desc}"
        "$mod, 5, moveworkspacetomonitor, 5  monitor:desc:${m1.desc}"
        "$mod, 6, moveworkspacetomonitor, 6  monitor:desc:${m2.desc}"
        "$mod, 7, moveworkspacetomonitor, 7  monitor:desc:${m2.desc}"
        "$mod, 8, moveworkspacetomonitor, 8  monitor:desc:${m2.desc}"
        "$mod, 9, moveworkspacetomonitor, 9  monitor:desc:${m2.desc}"
        "$mod, 0, moveworkspacetomonitor, 10 monitor:desc:${m2.desc}"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        "$mod ALT SHIFT, 1, movetoworkspace, 6"
        "$mod ALT SHIFT, 2, movetoworkspace, 7"
        "$mod ALT SHIFT, 3, movetoworkspace, 8"
        "$mod ALT SHIFT, 4, movetoworkspace, 9"
        "$mod ALT SHIFT, 5, movetoworkspace, 10"
      ];

      bindm = [
        # Pick up & drag
        "$mod, mouse:272, movewindow"
        # Resize
        "$mod, mouse:273, resizewindow"
      ];

      monitor = [
        # 10 bit breaks Vesktop screen share
        "desc:${m1.desc}, modeline ${m1.mode}, ${m1.pos}, ${m1.scale}, bitdepth,${m1.bitdepth}"
        "desc:${m2.desc}, modeline ${m2.mode}, ${m2.pos}, ${m2.scale}, bitdepth,${m2.bitdepth}"
      ];

      workspace = [
        "w[t1], gapsout:0, gapsin:0, bordersize:0"
        "f[1], gapsout:0, gapsin:0, bordersize:0"

        "1, persistent:true, monitor:desc:${m1.desc}, default:true"
        "2, persistent:true, monitor:desc:${m1.desc}"
        "3, persistent:true, monitor:desc:${m1.desc}"
        "4, persistent:true, monitor:desc:${m1.desc}"
        "5, persistent:true, monitor:desc:${m1.desc}"
        "6, persistent:true, monitor:desc:${m2.desc}, default:true"
        "7, persistent:true, monitor:desc:${m2.desc}"
        "8, persistent:true, monitor:desc:${m2.desc}"
        "9, persistent:true, monitor:desc:${m2.desc}"
        "10, persistent:true, monitor:desc:${m2.desc}"
      ];

      exec-once = [
        "[workspace 1 silent] firefox & steam -silent & easyeffects --gapplication-service &"
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "blueman-applet & nm-applet"
        "PATH=${pkgs.bash}/bin:$PATH waybar & eww daemon --no-daemonize & dunst"
        "[workspace m silent] spotify"
        "[workspace 2 silent] obsidian"
        # wait up to 10 seconds for easyeffects before starting apps which depend on its pipewire input
        "[workspace m silent] i=10; while [ ! $(${util.commands.pgrep} easyeffects) ] && [ $i -gt 0 ]; do sleep 1; ((i--)); done; vesktop & ts3client & disown"
        "[workspace 7 silent] hydroxide serve; sleep 2; thunderbird"
      ];
    };
  };
}
