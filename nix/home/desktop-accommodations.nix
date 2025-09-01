{ pkgs, ... }:
{
  #    imports = [
  #      ./apps-accommodations.nix
  #      ./base-accommodations.nix
  #    ];

  #nixpkgs.overlays = [
  #  (_: prev: {
  #    python312 = prev.python312.override { packageOverrides = _: pysuper: { nose = pysuper.pynose; }; };
  #  })
  #];

  # alacritty for nautilus
  programs.nautilus-open-any-terminal.enable = true;

  # GNOME Disks
  programs.gnome-disks.enable = true;
  services.udisks2.enable = true;

  # # Thunar
  # programs.thunar.enable = true;
  # programs.xfconf.enable = true; # Required for Thunar to save its config
  # services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for image
  # programs.thunar.plugins = with pkgs.xfce; [
  #   thunar-archive-plugin
  #   thunar-volman
  # ];

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  # for nix-index command not found integration
  programs.command-not-found.enable = false;

  # Run non-NixOS binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;
}
