{ pkgs, inputs, ... }:
let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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

    # __VK_LAYER_NV_optimus="NVIDIA_only";
    #   #  SDL_VIDEODRIVER="wayland";
    # SDL_VIDEODRIVER = "wayland,x11,windows";
    # SDL2_VIDEO_DRIVER = "wayland,x11,windows";
    #
    # CLUTTER_BACKEND="wayland";
    # GDK_BACKEND = "wayland,x11,*";
    # MOZ_ENABLE_WAYLAND=1;
    # MOZ_DISABLE_RDD_SANDBOX=1;
    # _JAVA_AWT_WM_NONREPARENTING=1;
    # QT_AUTO_SCREEN_SCALE_FACTOR=1;
    # QT_QPA_PLATFORM = "wayland;xcb";
    # PROTON_ENABLE_NGX_UPDATER=1;
    # #WLR_USE_LIBINPUT=1; #
    # XWAYLAND_NO_GLAMOR = 1; # with this you'll need to use gamescope for gaming
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
    QT_QPA_PLATFORMTHEME = "qt5ct";
    # QT_STYLE_OVERRIDE = "qt5ct-style";

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
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.nautilus.preferences]
    default-folder-viewer='list-view'
  '';

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "alacritty";
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.valent;
    #indicator = true;
  };

  # for blueman-applet/dbus-update-activation-environment
  #services.dbus.socketActivated = true;

  # Brightness control
  hardware.brillo.enable = true;

  hardware.graphics = {
    # i want no video please
    enable = true;
    package = pkgs-unstable.mesa;
    package32 = pkgs-unstable.pkgsi686Linux.mesa;

    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
  };

  environment.systemPackages = (
    with pkgs;
    [
      #hyprlock
      #hypridle
      hyprshade
      hyprpicker

      # not showkey
      wev

      # need for gui auth
      polkit_gnome

      # unsure which atm
      waybar
      eww

      wl-clipboard
      wofi
      xsel
      slurp
      hyprshot
      dunst
      #  fnott

      blueman
      # networkmanagerapplet

      playerctl
      pwvucontrol
      #    xdg-desktop-portal-hyprland
      xdg-desktop-portal-gnome
      gradience
      adw-gtk3
      arc-icon-theme
    ]
  );
}
