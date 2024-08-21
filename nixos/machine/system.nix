{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Network adapter configuration
    ./network.nix

    # Graphics driver configuration
    ../graphics/machine.nix

    # Audio server configuration
    ../audio.nix

    # Mouse configuration
    ../logitech.nix

    # VM host configuration
    ./virtualization.nix
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/d7a32074-19be-43e4-8be0-a00132726527";
      fsType = "ext4";
      options = [
        "defaults"
        "nodev"
        "noatime"
        "discard"
        "data=ordered"
      ];
    };

fileSystems."/boot" =
  {
    device = "/dev/disk/by-uuid/0FC1-0ECD";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8d82561f-b4a6-41fb-a200-3e4039a995de";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/71331833-459a-4a50-afab-b07a1800bb63";
    label = "Data";
    fsType = "ext4";
    neededForBoot = true;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "discard"
      "data=ordered"
    ];
  };

  fileSystems."/mnt/work" = {
    label = "Projects";
    device = "/dev/disk/by-uuid/0A10902A10901F2F";
    options = [
      "defaults"
      "nodev"
      "noatime"
      "discard"
      "data=ordered"
    ];
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.zfs.forceImportRoot = false;
  networking.hostId = "c71d4fae";

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHybridSleep=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
  '';

  # Causing periodic I/O freezes?
  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.powertop.enable = true;

  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" "sshfs" "btrfs" ];
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
