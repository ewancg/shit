# desktop.nix; home config for items specific to the NixOS user

{ pkgs, ... }:
with pkgs;
let
  segoe-ui-variable-fonts = callPackage ../misc/segoe-ui-variable/default.nix { };
  san-francisco-fonts = callPackage ../misc/san-francisco-font/default.nix { };
in
{
  imports = [
    #../misc/spicetify.nix

    #./apps.nix
    #./base.nix
  ];

  home = {
    packages = [
      # Theming
      adw-gtk3
      gruvbox-dark-gtk
      gruvbox-gtk-theme
      gruvbox-material-gtk-theme
      # catppuccin-gtk
      # catppuccin-kvantum
      gradience
      kdePackages.breeze
      kdePackages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
      kdePackages.qt6ct
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
      san-francisco-fonts
      cantarell-fonts

      ## Windows fonts
      #wine64Packages.fonts
      #winePackages.fonts
      #wineWow64Packages.fonts
      #wineWowPackages.fonts

      # Linux exclusive CLI
      grim
      playerctl
      traceroute

      # Linux system
      glibcLocales

      # NixOS
      nix-ld
    ];
    pointerCursor = {
      gtk.enable = true;
      name = "Yaru";
      package = pkgs.yaru-theme;
    };
  };

  xdg.configFile = let 
  dirs = lib.genAttrs [ "wofi" "eww" "waybar" "dunst" ] (name: { 
    source = ../../dot/config + "/${name}";
    recursive = true;
  });
  in
    dirs;
#    "wofi" = {
#      recursive = true;
#      source = ../../dot/config/wofi;
#    };
#    "eww" = {
#      recursive = true;
#      source = ../../dot/config/eww;
#    };
#    "waybar"= {
#      recursive = true;
#      source = ../../dot/config/waybar;
#    };
#    "dunst" = {
#      recursive = true;
#      source = ../../dot/config/dunst;
#    };

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
}
