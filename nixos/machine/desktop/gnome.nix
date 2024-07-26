{ pkgs, ... }:
{
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Apply a triple buffering patch for mutter which improves performance
  nixpkgs.overlays = [
    # GNOME 46: triple-buffering-v4-46
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "vanvugt";
            repo = "mutter";
            rev = "triple-buffering-v4-46";
            hash = "sha256-nz1Enw1NjxLEF3JUG0qknJgf4328W/VvdMjJmoOEMYs=";
          };
        });
      });
    })
  ];
  nixpkgs.config.allowAliases = false;

  # Enable list view in Nautilus and fractional scaling in Mutter
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.nautilus.preferences]
    default-folder-viewer='list-view'
    
    [org.gnome.mutter]
    experimental-features="['scale-monitor-framebuffer']"
  '';

  # Nautilus
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "alacritty";
  };



  environment = {
    sessionVariables = {
      NAUTILUS_4_EXTENSION_DIR = "${pkgs.gnome.nautilus-python}/lib/nautilus/extensions-4";
      # Nvidia
    NVD_BACKEND ="direct";
    LIBVA_DRIVER_NAME="nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

# Wayland
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland,x11";
    GDK_BACKEND="wayland,x11,*";

    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";

# GNOME
    QT_WAYLAND_DECORATION = "adwaita";
    XDG_CURRENT_DESKTOP="GNOME";
    XDG_SESSION_DESKTOP = "GNOME";

# Qt
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
#    QT_QPA_PLATFORMTHEME = "gnome";
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
    QT_STYLE_OVERRIDE = "kvantum";

    };
    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];

    gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs; [
      cheese # camera
      gnome-terminal
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player

      gnome.gnome-music
      gnome.gnome-characters
      gnome.tali # poker game
      gnome.iagno # go game
      gnome.hitori # sudoku game
      gnome.atomix # puzzle game
    ]);
    systemPackages = (with pkgs; [
      nautilus
      nautilus-python

      # GNOME & desktop integration
      dconf-editor
      gnome-tweaks
      yaru-theme

      qgnomeplatform
      qgnomeplatform-qt6
      xdg-desktop-portal
    ]);
  };
}
