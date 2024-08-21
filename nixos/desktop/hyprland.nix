{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    #systemd.enable = true;
  #  package = hyprland.
  };
  services.hypridle.enable = true;

  environment.sessionVariables = {
    # XWayland scaling is disabled
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    #HYPRCURSOR_SIZE = "192";

    # How to do these only on XWayland?
    # QT_SCALE_FACTOR,1.5
    # GDK_SCALE,1.5

    # Allow tearing on kernels < 6.8
    # WLR_DRM_NO_ATOMIC = 1;

    # Nvidia
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = 1;
    __GL_VRR_ALLOWED = 1; # Change if problematic; should work on 555

    # Wayland
    XDG_SESSION_TYPE = "wayland";
    # https://www.reddit.com/r/linux_gaming/comments/1cvrvyg/psa_easy_anticheat_eac_failed_to_initialize/
    SDL_VIDEODRIVER = "wayland,x11,windows";
    SDL2_VIDEO_DRIVER = "wayland,x11,windows";
    GDK_BACKEND = "wayland,x11,*";

    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";

    # Hyprland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Qt
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";

    # GTK
    GTK_THEME = "adw-gtk3";

  };

  # wayland.windowManager.hyprland.settings = {
  #decoration = {
  #  shadow_offset = "0 5";
  #  "col.shadow" = "rgba(00000099)";
  #};
  #
  #"$mod" = "SUPER";
  #
  #bindm = [
  #  # mouse movements
  #  "$mod, mouse:272, movewindow"
  #  "$mod, mouse:273, resizewindow"
  #  "$mod ALT, mouse:272, resizewindow"
  #];
  #};

  # Enable list view in Nautilus
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.nautilus.preferences]
    default-folder-viewer='list-view'
  '';

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  security.polkit.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "alacritty";
  };

  # programs.kdeconnect = {
  #   enable = true;
  #   package = pkgs.valent;
  #   # indicator = true;
  # };

  # for blueman-applet/dbus-update-activation-environment
  #services.dbus.socketActivated = true;

  environment.systemPackages = (with pkgs; [
    hyprlock
    hypridle
    hyprpicker
    
    # need for gui auth
    polkit_gnome

    # unsure which atm
    waybar
    eww

    wl-clipboard
    wofi
    xsel

    dunst
    #  fnott

    blueman
    networkmanagerapplet

    playerctl
    pwvucontrol
#    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gnome

  ]);
}
