{ pkgs, ... }:
{
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;

    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  services.pipewire.wireplumber.enable = true;
  services.pipewire.wireplumber.extraConfig = {
    alsaUseUCM = { "monitor.alsa.properties" = {
      # Use ALSA-Card-Profile devices. They use UCM or the profile
      # configuration to configure the device and mixer settings.
      # alsa.use-acp = true;
      # Use UCM instead of profile when available. Can be disabled
      # to skip trying to use the UCM profile.
      "alsa.use-ucm" = true;
    };};

    bluetoothEnhancements = { "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
    };};
  };
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-lowlatency.lua" ''
      alsa_monitor.rules = {
        {
          matches = {{{ "node.name", "matches", "alsa_output.*" }}};
          apply_properties = {
            ["audio.format"] = "S32LE",
            ["audio.rate"] = "96000", -- for USB soundcards it should be twice your desired rate
            ["api.alsa.period-size"] = 2, -- defaults to 1024, tweak by trial-and-error
            -- ["api.alsa.disable-batch"] = true, -- generally, USB soundcards use the batch mode
          },
        },
      }
    '')
  ];
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 96000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };

services.pipewire.extraConfig.pipewire."51-alsa-disable" = {
    monitor.alsa.rules = [{
        matches = [
        {device.name = "alsa_card.pci-0000_0d_00.1";} # onboard audio
        {device.name = "alsa_card.usb-Generic_USB_Audio-00";} # unsure
        {device.name = "alsa_card.pci-0000_01_00.1";} # GPU
        ];
        actions = {
          update-props = {
             device.disabled = true;
          };
        };
    }];
};

  # PulseAudio compatibility
  services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
    context.modules = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          pulse.min.req = "32/96000";
          pulse.default.req = "32/96000";
          pulse.max.req = "32/96000";
          pulse.min.quantum = "32/96000";
          pulse.max.quantum = "32/96000";
        };
      }
    ];
    stream.properties = {
      node.latency = "32/96000";
      resample.quality = 1;
    };
  };
}
