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
  };

  services.pipewire.wireplumber.enable = true;
  services.pipewire.wireplumber.extraConfig = {
    node.features.audio.control-port = true;
    alsaUseUCM = {
      "monitor.alsa.properties" = {
        # Use ALSA-Card-Profile devices. They use UCM or the profile
        # configuration to configure the device and mixer settings.
        # alsa.use-acp = true;
        # Use UCM instead of profile when available. Can be disabled
        # to skip trying to use the UCM profile.
        "alsa.use-ucm" = true;
      };
    };

    bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;

        "bluez5.codecs" = [
          "ldac"
          "aptx"
          "aptx_11_duplex"
          "aptx_11"
          "aptx_hd"
          "opus_05_pro"
          "opus_05_71"
          "opus_05_51"
          "opus_05"
          "opus_05_duplex"
          "aac"
          "sbc_xq"
        ];

        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "bap_sink"
          "bap_source"
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
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
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-stop-microphone-auto-adjust.lua" ''
      table.insert (default_access.rules,{
          matches = {
              {
                  { "application.process.binary", "!=", ".pwvucontrol-wr" }
              }
          },
          default_permissions = "rx",
      })
    '')
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-config.lua" ''
      alsa_monitor.enabled = true

      alsa_monitor.rules = {
      {
      matches = {
                  {
                      {"device.name", "matches", "alsa_card.usb-Speed_Dragon_USB_Advanced_Audio_Device-00"}
                  },
              },
      
      apply_properties = {
                  ["audio.format"] = "s24le",
              },
          },
      },
      {
      matches = {
                  {
                      {"device.name", "matches", "alsa_card.usb-Focusrite_Scarlett_Solo_USB_Y71ERQT079EC70-00"}
                  },
              },
      
      apply_properties = {
                  ["audio.format"] = "s32le",
              },
          },
      }
    '')

  ];

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 96000;
      default.clock.allowed-rates = [ 44100 48000 88200 96000 192000 ];
      default.clock.quantum = 24;
      default.clock.min-quantum = 24;
      default.clock.max-quantum = 24;
    };
  };

  services.pipewire.extraConfig.pipewire."51-alsa-disable" = {
    monitor.alsa.rules = [{
      matches = [
        { device.name = "alsa_card.pci-0000_0d_00.1"; } # onboard audio
        { device.name = "alsa_card.usb-Generic_USB_Audio-00"; } # unsure
        { device.name = "alsa_card.pci-0000_01_00.1"; } # GPU
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
