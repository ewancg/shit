{pkgs, ...}:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };
  
  programs.virt-manager.enable = true;

  # Address "Could not detect a default hypervisor ..."
  dconf.settings = {
  "org/virt-manager/virt-manager/connections" = {
    autoconnect = ["qemu:///system"];
    uris = ["qemu:///system"];
  };
  };

  # Address "authentication unavailable: no polkit agent available ..."
  users.users.ewan.extraGroups = [ "libvirtd" ];
}