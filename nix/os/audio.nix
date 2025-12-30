{ pkgs, ... }:
let
  # "There is a very little quality difference between 10 and 14, but the CPU load difference is 2-3x"
  # AFAIK, if the destination sample rate is a multiple of the source, this virtually doesn't matter
  pipewireResampleQuality = 14;

  # Hardware supports it so whatever (I can not hear the difference)
  defaultSmpRate = 96000;

  # min quant is used as default because apps that know their callbacks will take longer use the
  # max buffer size to start with (firefox is an example)
  minQuant = 64;

  maxQuant = 256;

  buildQuantStr = (quant: "${builtins.toString quant}/${builtins.toString defaultSmpRate}");
  minQuantStr = buildQuantStr minQuant;
  maxQuantStr = buildQuantStr maxQuant;
in
{
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    # It would be nice to enable this, but it would require better propagation of dbus environment
    # variables to the pipewire service from the system-wide dbus session that is currently not
    # supported within any of the relevant unit files
    # I do not want my audio stopping when I enter a VT or something
    systemWide = false;

    enable = true;
    jack.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
  hardware.alsa.enablePersistence = true;
  hardware.alsa.enableOSSEmulation = true;

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

    # this section focuses mainly on preventing Bluetooth devices from using their embedded
    # microphones, because I have my own and I never want crunchy sbc audio
    bluetoothEnhancements = {
      "module-allow-priority" = false;
      "bluetooth.autoswitch-to-headset-profile" = {
        description = "Whether or not to auto-switch to the Bluetooth headset protocol (duplex)";
        type = "bool";
        default = false;
      };
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              "device.name" = "~bluez_card.*";
              "device.product.id" = "*";
              "device.vendor.id" = "*";
            }
          ];
          actions = {
            update-props = {
              # Set codec qualities to their highest settings instead of the "balanced" defaults
              "bluez5.*.ldac.quality" = "hq";
              "bluez5.a2dp.aac.bitratemode" = "5";
              "device.profile" = "a2dp-sink";
            };
          };
        }
      ];

      "monitor.bluez.properties" = {
        #"bluez5.enable-sbc-xq" = true;
        #"bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;

        "bluez5.codecs" = [
          "sbc"
          "sbc_xq"
          "aac"
          "ldac"
          "aptx"
          "aptx_hd"
          "aptx_ll"
          "aptx_ll_duplex"
          "faststream"
          "faststream_duplex"
          "lc3plus_h3"
          "opus_05"
          "opus_05_51"
          "opus_05_71"
          "opus_05_duplex"
          "opus_05_pro"
          "lc3"
        ];

        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "bap_sink"
          "bap_source"
          "hsp_hs"
          "hsp_ag"

          # comment these out to enable duplex mode
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
  };

  services.pipewire.wireplumber.configPackages = [
    # (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-disable-devices.conf" ''
    #   monitor.alsa.rules = [
    #     {
    #       matches = [
    #         { device.name = "~alsa_card.pci-*" },
    #         { device.bus = "pci" },
    #
    #         # Motherboard audio
    #         { device.name = "alsa_card.pci-0000_0d_00.1" },
    #
    #         # GPU audio
    #         { device.name = "alsa_card.pci-0000_01_00.1" },
    #         { device.vendor.name = "NVIDIA Corporation" },
    #         { device.nick = "HDA NVidia" },
    #         { object.path = "alsa:acp:NVidia" },
    #
    #         # Should be caught by the above (NVIDIA ones weren't working anyway)
    #         { device.name = "alsa_card.usb-Generic_USB_Audio-00" }, # unsure
    #         { device.name = "alsa_card.usb-046d_HD_Pro_Webcam_C920_F7571F4F-02"; }, # Webcam
    #       ]
    #       actions = {
    #         update-props = {
    #         	device.disabled = true
    #         }
    #       }
    #     }
    #   ]
    # '')
    # (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/99-alsa-lowlatency.conf" ''
    #   monitor.alsa.rules = [
    #   {
    #     matches = [ { alsa.card_name = "Scarlett Solo USB" } ]
    #     actions = {
    #       update-props = {
    #         "node.latency" = "${minQuantStr}"
    #         "audio.format" = "S32LE"
    #         "audio.rate" = ${builtins.toString defaultSmpRate}
    #         "audio.allowed-rates" = "32000,44100,48000,96000,192000"
    #         "audio.channels" = 2
    #         "audio.position" = "FL,FR"
    #       }
    #     }
    #   }
    #   {
    #     matches = [ { device.name = "alsa_card.usb-Speed_Dragon_USB_Advanced_Audio_Device-00" } ]
    #     actions = {
    #       update-props = {
    #         "node.latency" = "${minQuantStr}"
    #         "audio.format" = "S24LE"
    #         "audio.rate" = ${builtins.toString defaultSmpRate}
    #         "audio.allowed-rates" = "32000,44100,48000,96000"
    #         "audio.channels" = 2
    #         "audio.position" = "FL,FR"
    #       }
    #     }
    #   }
    #   ]
    # '')

    # Certain web-apps have built-in "automatic gain control" which just changes the input device's volume
    # Disabling it in-app doesn't seem to work for the main perp (Discord), so we will whitelist pwvucontrol
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/98-stop-microphone-auto-adjust.lua" ''
      table.insert (default_access.rules,{
          matches = {
              {
                  { application.process.binary = "!~pwvucontrol.*" }
              }
          }
          default_permissions = "rx",
      })
    '')
  ];

  services.pipewire.extraConfig.pipewire."92-rates" = {
    context.properties = {
      default.clock.rate = defaultSmpRate;
      default.clock.allowed-rates = [
        32000
        44100
        48000
        88200
        96000
        192000
      ];
      default.clock.quantum = minQuant;
      default.clock.min-quantum = minQuant;
      default.clock.max-quantum = maxQuant;
    };
  };

  # PulseAudio compatibility
  services.pipewire.extraConfig.pipewire-pulse."97-rates" = {
    context.modules = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          pulse.default.req = minQuantStr;

          pulse.min.quantum = minQuantStr;
          pulse.min.req = minQuantStr;

          pulse.max.quantum = maxQuantStr;
          pulse.max.req = maxQuantStr;
        };
      }
    ];
    stream.properties = {
      node.latency = minQuantStr;
      resample.quality = pipewireResampleQuality;
    };
  };

  services.pipewire.extraConfig.pipewire."99-disable-devices" = {
    monitor.alsa.rules = [
      {
        matches = [
          # I only use a USB one
          { device.bus = "pci"; }
          { device.name = "~alsa_card.pci-*"; }

          # Explicitly disable motherboard audio
          { device.name = "alsa_card.pci-0000_0d_00.1"; }

          # Explicitly disable GPU audio (it doesn't even work)
          { device.name = "alsa_card.pci-0000_01_00.1"; }
          { device.sysfs.path = "/devices/pci0000:00/0000:00:01.1/0000:01:00.1/sound/card0"; }
          { device.vendor.name = "NVIDIA Corporation"; }
          { device.nick = "HDA NVidia"; }
          { object.path = "alsa:acp:NVidia"; }

          { device.name = "alsa_card.usb-Generic_USB_Audio-00"; } # unsure
          { device.name = "alsa_card.usb-046d_HD_Pro_Webcam_C920_F7571F4F-02"; } # Webcam
        ];
        actions = {
          update-props = {
            device.disabled = true;
          };
        };
      }
    ];
  };
}
