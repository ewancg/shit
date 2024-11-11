# Derived from https://github.com/rhasselbaum/nixos-config/blob/main/hosts/caprica/network-and-virt.nix
{ config, lib, pkgs, nixvirt, ... }:

let
  libvirt_nat_bridge_dev = "virbr0";
  libvirt_sandbox_dev = "sandbox0";
  #nixvirt = inputs.nixvirt;
in
{
  imports = [ nixvirt.nixosModules.default ];

  # Check!.
  networking.networkmanager.enable = true;
  # Don't try to manage the libvirt bridges.
  networking.networkmanager.unmanaged = [ libvirt_nat_bridge_dev libvirt_sandbox_dev ];

  # Podman
  # virtualisation = {
  #   containers.enable = true;
  #   podman = {
  #     enable = true;
# 
  #     # Required for containers under podman-compose to be able to talk to each other.
  #     defaultNetwork.settings.dns_enabled = true;
  #   };
  # };

  # Libvirt + QEMU + KVM with NixVirt
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = nixvirt.lib.network.writeXML (nixvirt.lib.network.templates.bridge {
            name = "default";
            uuid = "1c90d1b8-7db9-4314-a598-ebe213a68b4c";
            subnet_byte = 122;
            bridge_name = libvirt_nat_bridge_dev;
          });
          active = true;
        }
        {
          definition = nixvirt.lib.network.writeXML {
            name = "sandbox";
            uuid = "53e8b369-419f-4a2e-b244-071e60c2d3e5";
            bridge.name = libvirt_sandbox_dev;
            ip = {
              address = "192.168.123.1";
              netmask = "255.255.255.0";
              dhcp.range = { start = "192.168.123.2"; end = "192.168.123.254"; };
            };
          };
          active = true;
        }
      ];
    };
  };

  virtualisation.libvirtd = {
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true; # Doesn't actually run as root because of overriding config below.
      # We want to run as a specific user/group, not Nix's non-root default of `qemu-libvirtd`,
      verbatimConfig =
      ''
        namespaces = []
        user = "ewan"
        group = "users"
      '';
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  programs.virt-manager.enable = true;
  users.users.ewan.extraGroups = [ "libvirtd" ];

  # Open ports in the firewall.
  networking.firewall.trustedInterfaces = [ libvirt_sandbox_dev libvirt_nat_bridge_dev ]; # Allow traffic on the container sandbox bridge.
}