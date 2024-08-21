{ config, ... }:

{
  # Graphics configuration to run Optimus with an RTX 3060 (nvidia) behind AMD integrated graphics (amdgpu)
  # https://nixos.wiki/wiki/Nvidia

  # Enable OpenGL
  hardware.graphics = {
    enable32Bit = true;
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    # False because it requires PRIME offload mode

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # hardware.nvidia.prime = {
  #   # Offload mode
  #   offload = {
  #     enable = true;
  #     enableOffloadCmd = true;
  #   };
  #   # Sync mode 
  #   # sync.enable = true;

  #   # Getting PCI IDs of GPUs
  #   # sudo lshw -c display; "bus info"
  #   #   pci@0000:0d:00.0
  #   # take last 7 characters
  #   #   0d:00.0
  #   # convert hex to decimal
  #   #   13:00.0
  #   # replace '.' with ':'
  #   #   13:00:0
  #   # prepend "PCI:"
  #   #   PCI:13:00:0

  #   amdgpuBusId = "PCI:13:00:0";
  #   nvidiaBusId = "PCI:01:00:0";
  # };

  # 
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    nvidia_x11
  ];

  environment.variables = {
        # Nvidia
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = 1;
    __GL_VRR_ALLOWED = 1; # Change if problematic; should work on 555


    VK_DRIVER_FILES = /run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json;
  };
  boot.blacklistedKernelModules = [
    "nouveau"
  ];

  boot.extraModprobeConfig = ''
    options nvidia_drm modeset=1 fbdev=1
    options nouveau modeset=0
  '';
}
