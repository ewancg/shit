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
        alsa.use-acp = true;
        # Use UCM instead of profile when available. Can be disabled
        # to skip trying to use the UCM profile.
        # "alsa.use-ucm" = true;
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
        -- Unimportant sound cards
        {
          matches = {{{ "node.name", "matches", "alsa_output.*" }}};
          apply_properties = {
            ["resample.quality"]       = 14,

            ["node.pause-on-idle"]     = false,
            ["node.suspend-on-idle"]   = false,
            ["session.suspend-timeout-seconds"] = 0,

            ["priority.driver"]        = 100,
            ["priority.session"]       = 100,
            ["channelmix.normalize"]   = false,
            ["channelmix.mix-lfe"]     = false,

            ["api.alsa.period-size"]   = 512,
            ["api.alsa.headroom"]      = 0,
            ["api.alsa.disable-mmap"]  = false,
            ["api.alsa.disable-batch"] = false,            
          },
        },

        -- Scarlett Solo USB
        {
          matches = {
            {
              { "alsa.card_name", "matches", "Scarlett Solo USB" }
              -- { "device.name", "matches", "alsa_card.usb-Focusrite_Scarlett_Solo_USB_Y71ERQT079EC70-00" }
              -- { "node.name", "matches", "alsa_input.*" },
            },
            {
              -- Matches all sinks.
              { "node.name", "matches", "alsa_output.*" },
            },
          },
          apply_properties = {
            ["node.nick"]              = "Scarlett Solo USB",
            ["node.latency"]           = "512/192000"
            ["audio.format"]           = "S32LE",
            ["audio.rate"]             = 192000,
            ["audio.allowed-rates"]    = "32000,44100,48000,96000,192000"
            ["audio.channels"]         = 2,
            ["audio.position"]         = "FL,FR",
          },
        },
        
        -- Syba Sonic USB
        {
          matches = {
            {
              { "device.name", "matches", "alsa_card.usb-Speed_Dragon_USB_Advanced_Audio_Device-00" },
              { "node.name", "matches", "alsa_output.usb-Speed_Dragon_USB_Advanced_Audio_Device-00.iec958-stereo" }
            },
          },
          apply_properties = { 
              ["node.nick"]              = "Syba Sonic USB",
              ["node.latency"]           = "512/96000"
              ["audio.format"]           = "S24LE",
              ["audio.rate"]             = 96000,
              ["audio.allowed-rates"]    = "32000,44100,48000,88200,96000"
              ["audio.channels"]         = 2,
              ["audio.position"]         = "FL,FR",
            },
          },
        },
      }
    '')
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-stop-microphone-auto-adjust.lua" ''
      table.insert (default_access.rules,{
          matches = {
              {
                  { application.process.binary != ".pwvucontrol-wr" }
              }
          }
          default_permissions = "rx",
      })
    '')
  ];

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 96000;
      default.clock.allowed-rates = [ 32000 44100 48000 88200 96000 192000 ];
      default.clock.quantum = 512;
      default.clock.min-quantum = 512;
      default.clock.max-quantum = 1024;
    };
  };

  services.pipewire.extraConfig.pipewire."51-alsa-disable" = {
    monitor.alsa.rules = [{
      matches = [
        { device.name = "alsa_card.pci-0000_0d_00.1"; } # onboard audio
        { device.name = "alsa_card.pci-0000_01_00.1"; } # GPU
        { device.name = "alsa_card.usb-Generic_USB_Audio-00"; } # unsure
        { device.name = "alsa_card.usb-046d_HD_Pro_Webcam_C920_F7571F4F-02"; } # GPU
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
      resample.quality = 14;
    };
  };
}
