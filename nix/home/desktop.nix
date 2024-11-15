# desktop.nix; home config for items specific to the NixOS user

{ pkgs, ... }:
with pkgs;
let
  segoe-ui-variable-fonts = callPackage ../misc/segoe-ui-variable/default.nix { };
in
{
  imports = [
    ./apps.nix
    ./base.nix
   # ../misc/spicetify.nix
  ];

  home = {
    packages = [
      # Theming
      adw-gtk3
      arc-icon-theme
      arc-theme
      ayu-theme-gtk
      breeze-gtk
      catppuccin-gtk
      catppuccin-kvantum
      gradience
      kdePackages.breeze
      kdePackages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum
      lightly-boehs
      qt5ct
      kdePackages.qt6ct
      solarc-gtk-theme
      themechanger
      yaru-theme

      # Cross-desktop utilities
      gnome-calendar
      evolution-ews
      gnome-calculator
      gnome-font-viewer

      ## System monitors
      gnome-disk-utility
      gnome-system-monitor
      mission-center
      nvtopPackages.full

      ## Wine
      proton-caller
      vkd3d-proton
      #wine-wayland
      #wine64
      winetricks
      #wineWowPackages.stable
      wineWowPackages.waylandFull

      # Fonts
      segoe-ui-variable-fonts
      
      ## Windows fonts
      segoe-ui-variable-fonts
      #wine64Packages.fonts
      #winePackages.fonts
      #wineWow64Packages.fonts
      #wineWowPackages.fonts

      # Not Windows fonts
      cantarell-fonts
      corefonts
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      noto-fonts
      open-sans
      ubuntu_font_family
      ucs-fonts
      vistafonts
      zilla-slab

      # Conflict
      # proggyfonts
      # dina-font
    ];
    pointerCursor = {
      gtk.enable = true;
      name = "Catppuccin-Mocha-Light-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
  };

  xdg.configFile = {
    "Kvantum".source  = ../../dot/Kvantum;
    "qt5ct".source    = ../../dot/qt5ct;
    "qt6ct".source    = ../../dot/qt6ct;
    "wofi".source     = ../../dot/wofi;
    "hypr".source     = ../../dot/hypr;
    "eww".source      = ../../dot/eww;
    "waybar".source   = ../../dot/waybar;
    "dunst".source    = ../../dot/dunst;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "audio/" = "vlc.desktop";
      "text/" = "code.desktop";
      "image/" = "photoflare.desktop";
      "text/html" = "firefox.desktop";
      "application/" = "firefox.desktop"; # PDF, .docx, etc..
      "application/gz" = "nautilus.desktop"; # PDF, .docx, etc..
      
      
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  services = {
    kdeconnect = {
      enable = true;
      # valent on Hyprland; gsconnect on GNOME
      package = pkgs.valent;
      indicator = true;
    };

    # May not be needed on GNOME
    gammastep = {
      enable = true;
      tray = true;
      #provider = "geoclue2";
      provider = "manual";
      latitude = 39.9;
      longitude = -105.1;

      temperature.day = 6000;
      temperature.night = 4000;
    };

    # mpd = {
    #   enable = true;
    #   musicDirectory = "/mnt/music";
    #   extraConfig = ''
    #     audio_output {
    #       type "pipewire"
    #       name "pipewire"
    #     }'';
    #   # Optional:
    #   network.listenAddress = "any"; # if you want to allow non-localhost connections
    #   network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
    # };
  };

  dconf = {
    enable = true;
    settings = {
      # Address "Could not detect a default hypervisor ..."
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };

      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          gsconnect.extensionUuid
          tiling-assistant.extensionUuid
          window-calls.extensionUuid
          window-calls-extended.extensionUuid
          ddnet-friends-panel.extensionUuid
          user-themes.extensionUuid
          dash-to-panel.extensionUuid
          quick-settings-audio-panel.extensionUuid
          # tray-icons-reloaded.extensionUuid
          appindicator.extensionUuid
        ];
      };
    };
  };
}