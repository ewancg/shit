#!/usr/bin/env bash

mount --mkdir /dev/disk/by-uuid/d7a32074-19be-43e4-8be0-a00132726527 /run/root
mount --mkdir /dev/disk/by-uuid/E0A1-2614 /run/boot
mount --mkdir /dev/disk-by-uuid/8d82561f-b4a6-41fb-a200-3e4039a995de /run/nix

mount --mkdir --bind /run/root /mnt
mount --mkdir --bind /run/boot /mnt/boot
mount --mkdir --bind /run/nix /mnt/nix
