{ pkgs, lib, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Network adapter configuration
    ./network.nix

    # Graphics driver configuration
    ./graphics.nix

    # Audio server configuration
    ./audio.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.zfs.forceImportRoot = false;
  networking.hostId = "c71d4fae";

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHybridSleep=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
  '';

  home-manager.users.gdm = { lib, ... }: {
    home.stateVersion = "18.09";
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        scaling-factor = lib.hm.gvariant.mkUint32 2;
      };
  };
  };

  # Causing periodic I/O freezes?
  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.powertop.enable = true;

  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.supportedFilesystems = [ "ntfs" "sshfs" ];
  # boot.supportedFilesystems = [ "ntfs" "sshfs" "zfs" ];

  # Extra kernel modules
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  # OpenRGB udev rules
  services.hardware.openrgb.enable = true;
  #  services.udev.extraRules =
  #    builtins.replaceStrings ["/bin/chmod"] ["${lib.getExe' pkgs.coreutils "chmod"}"] ''
  #    ${builtins.readFile ./udev/60-openrgb.rules}
  #    '';

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
}