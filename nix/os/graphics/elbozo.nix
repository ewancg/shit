{ config, ... }:

{
  # Graphics configuration to run AMD integrated graphics (amdgpu)
  # https://nixos.wiki/wiki/AMD_GPU

  # Enable OpenGL
  hardware.graphics = {
    enable32Bit = true;
    enable = true;
  };

  # Load amggpu driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    amdgpu
  ];

  environment.variables = {
    # Nvidia
    LIBVA_DRIVER_NAME = "radeonsi";

    # guessing now
    GBM_BACKEND = "amdgpu";
    __GLX_VENDOR_LIBRARY_NAME = "amdgpu";
    __GL_GSYNC_ALLOWED = 1;
    __GL_VRR_ALLOWED = 1; # Change if problematic; should work on 555
  };
}
