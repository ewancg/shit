{ config, ... }:
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptroot";
                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
                settings = {
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=root"
                        "compress=no"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "subvol=home"
                        "compress=no"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "subvol=nix"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "subvol=persist"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "subvol=log"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # if I need this, it's already over
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "24G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  swapDevices = [
    "/swap/swapfile"
  ];

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  #fileSystems."/" =
  #  {
  #    device = "/dev/disk/by-uuid/d7a32074-19be-43e4-8be0-a00132726527";
  #    fsType = "ext4";
  #    autoResize = false;
  #    options = [
  #      "defaults"
  #      "nodev"
  #      "noatime"
  #      "discard"
  #      "data=ordered"
  #    ];
  #  };
  #fileSystems."/boot" =
  #  {
  #    device = "/dev/disk/by-uuid/E0A1-2614";
  #    fsType = "vfat";
  #    autoResize = false;
  #    options = [ "fmask=0022" "dmask=0022" ];
  #  };
  #fileSystems."/nix" = {
  #  device = "/dev/disk/by-uuid/8d82561f-b4a6-41fb-a200-3e4039a995de";
  #  fsType = "btrfs";
  #  neededForBoot = true;
  #  autoResize = false;
  #  options = [
  #    "defaults"
  #    "nodev"
  #    "noatime"
  #    "compress=zstd"
  #  ];
  #};

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/71331833-459a-4a50-afab-b07a1800bb63";
    fsType = "ext4";
    neededForBoot = true;
    autoResize = false;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "discard"
      "data=ordered"
    ];
  };

  fileSystems."/mnt/work" = {
    device = "/dev/disk/by-uuid/0A10902A10901F2F";
    autoResize = false;
    options = [
      "defaults"
      "nodev"
      "noatime"
      "discard"
      "data=ordered"
    ];
  };

  boot = {
    kernelParams = [
      "resume_offset=533760"
    ];
    resumeDevice = "/dev/disk/by-label/nixos";
  };
}
