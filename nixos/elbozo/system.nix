{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Network adapter configuration
    ./network.nix

    # Graphics driver configuration
    # ../graphics/elbozo.nix

    # Audio server configuration
    ../audio.nix

    # Mouse configuration
    ../logitech.nix
  ];

  fileSystems."/boot" =
  {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
  swapDevices = [ {
    device = "/dev/nvme0n1p2";
  } ];
  fileSystems."/nix" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    autoResize = false;
    neededForBoot = true;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "compress=zstd"
    ];
  };
  fileSystems."/" = {
    device = "/dev/nvme0n1p4";
    fsType = "ext4";
    autoResize = false;
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

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
