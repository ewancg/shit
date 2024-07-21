{pkgs, ...}:
{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # systemd.enable = true;
  };
  services.hypridle.enable = true;
  
  environment.sessionVariables = {
    XCURSOR_SIZE = "64";
    HYPRCURSOR_SIZE = "64";
    NIXOS_OZONE_WL = "1";
    # Using latest kernel; needed on < 6.8
    #WLR_DRM_NO_ATOMIC = "1";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland,x11";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
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

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "alacritty";
  };

  environment.systemPackages = (with pkgs; [
    hyprlock

      nautilus
      nautilus-python
      
      yaru-theme
  ]);
}