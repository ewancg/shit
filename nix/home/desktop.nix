# desktop.nix; home config for items specific to the NixOS user

{
  config,
  pkgs,
  ...
}:
with pkgs;
let
  segoe-ui-variable-fonts = callPackage ../misc/segoe-ui-variable/default.nix { };
  san-francisco-fonts = callPackage ../misc/san-francisco-font/default.nix { };
in
{
  imports = [
    ./dunst.nix
    ./email.nix
    ./eww.nix
    ./fsearch.nix
    ./hyprland.nix
    ./qpalette.nix
    ./waybar.nix
    ./wofi.nix
  ];

  stylix.enable = true;
  stylix.icons.enable = false;
  gtk = {
    # theme = {
    #   name = "adw-gtk3";
    #   package = pkgs.adw-gtk3;
    # };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    cursorTheme = {
      name = "Yaru";
      package = pkgs.yaru-theme;
    };
  };

  stylix.targets.hyprland.enable = false;
  stylix.targets.qt.enable = false;
  stylix.targets.gtk.enable = true;
  stylix.targets.zed.enable = true;
  stylix.targets.btop.enable = true;
  stylix.targets.firefox = {
    enable = true;
    colorTheme.enable = true;
  };
  stylix.targets.gnome-text-editor.enable = false;
  #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  # https://github.com/ada-lovecraft/base16-nord-scheme/raw/refs/heads/master/nord.yaml
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  # stylix.base16Scheme = "${fetchurl { url = "https://github.com/tinted-theming/schemes/raw/refs/heads/spec-0.11/base24/arthur.yaml"; hash = "sha256-WwxZ239HbQ1wdIYERXbOPaDoHbmvJUBN+KFe3yLzsEk="; }}";
  # stylix.base16Scheme = "${repkgs.base16-schemes}/share/themes/nord.yaml";
  stylix.fonts = {
    serif = {
      package = san-francisco-fonts;
      name = "San Francisco Text";
    };
    # serif = {
    #   package = pkgs.source-serif-pro;
    #   name = "Source Serif Pro";
    # };
    sansSerif = {
      package = san-francisco-fonts;
      name = "San Francisco Text";
    };
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono NerdFont";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };

    sizes = {
      applications = 11;
      terminal = 11;
    };
  };
  stylix.targets.waybar.enable = true;
  #stylix.targets.vscode.enable = false;

  home = {
    packages = [
      # Theming
      adw-gtk3
      gruvbox-dark-gtk
      gruvbox-gtk-theme
      gruvbox-material-gtk-theme
      # catppuccin-gtk
      # catppuccin-kvantum
      #gradience
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
      # proton-caller
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
      nethogs

      # Linux system
      glibcLocales

      # NixOS
      nix-ld

      wpa_supplicant_gui

      # Create a runtime mechanism to read Stylix base16 (or 24) colors
      (
        let
          colorSetToBashCases = (
            col:
            builtins.concatStringsSep "\n" (
              builtins.map
                (
                  name:
                  let
                    key = (if (builtins.substring 0 4 name) == "base" then builtins.substring 4 (-1) name else name);
                  in
                  "\"${key}\") printf '${col.withHashtag.${name}}';;"
                )
                (
                  let
                    filter = (
                      str:
                      (builtins.substring 0 4 str) == "base"
                      || builtins.elem str [
                        "red"
                        "orange"
                        "yellow"
                        "green"
                        "cyan"
                        "blue"
                        "magenta"
                        "brown"
                        "bright-red"
                        "bright-yellow"
                        "bright-green"
                        "bright-cyan"
                        "bright-blue"
                        "bright-magenta"
                      ]
                    );
                    output = builtins.filter filter (builtins.attrNames col);
                  in
                  output
                )
            )
          );
        in
        writeShellScriptBin "get-color" ''
          case "$1" in
          ${colorSetToBashCases config.lib.stylix.colors}
          esac
          shift
        ''
      )
    ];
    pointerCursor = {
      gtk.enable = true;
      name = "Yaru";
      package = pkgs.yaru-theme;
    };
  };

  # No current need to arbitrarily emplace dotfiles, but this is a powerful little snippet
  #xdg.configFile =
  #  let
  #    dirs =
  #      lib.genAttrs
  #        [
  #          "wofi"
  #          "eww"
  #          "waybar"
  #          "dunst"
  #        ]
  #        (name: {
  #          source = ../../dot/config + "/${name}";
  #          recursive = true;
  #        });
  #  in
  #  dirs;

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
