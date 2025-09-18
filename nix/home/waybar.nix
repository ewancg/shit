{
  config,
  pkgs,
  util,
  ...
}:
let
  col = config.lib.stylix.colors;
  eww-toggle-window = "${pkgs.bash}/bin/bash ${../../dot/local/bin/eww-toggle-window}";
  h2d = util.hexColorToDecimalTriplet;
in
{
  home.packages = with pkgs; [
    waybar
    font-awesome
  ];

  xdg.configFile."waybar/config".text = ''
    ﻿[
        {
            "height": 28,
            "output": [ "Samsung Electric Company LF32TU87 HCPRA08903", "Chimei Innolux Corporation 0x1406" ],
            "layer": "top",
            "modules-left": [
                "custom/power",
                "hyprland/workspaces",
                "custom/spacer",
                "mpris"
            ],
            "modules-center": [
                "hyprland/window"
            ],
            "modules-right": [
                "wireplumber",
                "hyprland/language",
                "bluetooth",
                "network",
                "tray",
                "battery",
                "clock"
            ],
            "custom/spacer": {
                "class": "spacer",
                "format": " "
            },
            "custom/power": {
                "format": "<small>ewan</small>",
                "tooltip": false,
                "on-click": "${eww-toggle-window} power-menu"
            },
            "hyprland/workspaces": {
                "show-special": true,
                "sort": "id",
                "format": "{icon}",
                "format-icons": {
                    "1": "1",
                    "2": "2",
                    "3": "3",
                    "4": "4",
                    "5": "5",
                    "magic": "m"
                },
                "persistent-workspaces": {
                    "1": {},
                    "2": {},
                    "3": {},
                    "4": {},
                    "5": {},
                },
                "on-scroll-up": "hyprctl dispatch workspace e+1",
                "on-scroll-down": "hyprctl dispatch workspace e-1"
            },
            "hyprland/window": {
                "format": "{title} <small>{class}</small>",
                "max-length": 100,
                "separate-outputs": true
            },
                // "custom/music": {
                //   "format": "{player_icon} {dynamic}",
                //   "return-type": "json",
                //   "exec": "waybar-module-music",
                // },
            "mpris": {
                "interval": 1,
                "format": "{player_icon} {dynamic}",
                "player-icons": {
                    "firefox": "\uf269",
                    "spotify": "\uf1bc",
                    "psst-gui": "\uf1bc",
                    "spot": "\uf1bc",
                    "default": "\uf144"
                },
                "title-len": 65,
                "dynamic-separator": " •︎ ",
                "dynamic-len": 90
            },
            "battery": {
                "format": "{capacity}% {icon}",
                "format-icons": [
                    "",
                    "",
                    "",
                    "",
                    ""
                ]
            },
            "bluetooth": {
                "format": "{icon} <small>{controller_alias}</small>",
                "format-connected": "{icon} {num_connections} <small>{controller_alias}</small>",
                "format-icons": [
                    ""
                ],
                "on-click": "blueman-manager",
                "tooltip": true
            },
            "network": {
                "format-ethernet": "\uf6ff <small>{ifname}</small>",
                "format-wifi": "\uf1eb <small>{essid} •︎ {frequency}</small>",
                "format-disconnected": "\uf05e disconnected",
                "tooltip": true,
                "tooltip-format-ethernet": "{ifname} ({bandwidthTotalBits})",
                "on-click": "nm-connection-editor"
            },
            "wireplumber": {
                "format": "{icon} <small>{volume}%</small>",
                "format-muted": "\uf6a9",
                "on-click": "${eww-toggle-window} volume default --arg x=$(expr $(hyprctl cursorpos | awk '{print $1-1;}') - 40)",
                "on-click-right": "pwvucontrol",
                "format-icons": {
                    "default": [
                        "\uf027",
                        "\uf028"
                    ]
                }
            },
            "tray": {
                "icon-size": 16,
                "show-passive-items": true,
                "reverse-direction": true,
                "spacing": 4
            },
            "hyprland/language": {
                "format": "<small>{}</small>"
            },
            "clock": {
                "format": "{:%I:%M %p}",
                "format-alt": "{:%A, %B %d %I:%M %p}"
            }
        },
        {
            "height": 28,
            "layer": "top",
            "output": [ "Acer Technologies B326HK T1NAA0038522", "XYM MNN 0x00000055" ],
            "modules-left": [
                "hyprland/workspaces"
            ],
            "modules-center": [
                "hyprland/window"
            ],
            "modules-right": [
                "cpu",
                "memory",
                "disk",
                "battery",
                "clock"
            ],
            "cpu": {
                "interval": 1,
                "format": "<small> {usage:02d}%</small>",
                "format-alt": "<small> {usage:02d}%: {avg_frequency:0.2f} / {max_frequency:0.2f}</small><sub>GHz</sub>"
            },
            "memory": {
                "interval": 15,
                "format": "<small> {percentage:02d}%</small>",
                "format-alt": "<small> {percentage:02d}%: {used:0.1f} / {total:0.1f} </small><sub>GB</sub>"
            },
            "disk": {
                "interval": 90,
                "format": "<small> {percentage_used:02d}%</small>",
                "format-alt": "<small> {percentage_used:02d}%: {specific_used:0.1f} / {specific_total:0.1f} </small><sub>GB used </sub><small>({percentage_free:02d}% </small><sub>free</sub><small>)</small>",
                "unit": "GB"
            },
            "battery": {
                "format": "{capacity}% {icon}",
                "format-icons": [
                    "",
                    "",
                    "",
                    "",
                    ""
                ]
            },
            "hyprland/workspaces": {
                "sort": "id",
                "format": "{icon}",
                "show-special": true,
                "format-icons": {
                    "6": "A",
                    "7": "B",
                    "8": "C",
                    "9": "D",
                    "10": "E",
                    "magic": "m"
                },
                "persistent-workspaces": {
                    "6": {},
                    "7": {},
                    "8": {},
                    "9": {},
                    "10": {},
            },
                "on-scroll-up": "hyprctl dispatch workspace e+1",
                "on-scroll-down": "hyprctl dispatch workspace e-1"
            },
            "hyprland/window": {
                "format": "{title} <small>{class}</small>",
                "max-length": 100,
                "separate-outputs": true
            },
            "clock": {
                "format": "{:%I:%M %p}",
                "format-alt": "{:%A, %B %d   %I:%M %p}"
            }
        },
        {
            "output": "LG Electronics LG TV 0x01010101",
            "height": 24,
            "modules-left": [
                "hyprland/workspaces"
            ],
            "modules-center": [
                "hyprland/window"
            ],
            "modules-right": [
                "cpu",
                "memory",
                "disk",
                "hyprland/language",
                "battery",
                "clock"
            ],
            "hyprland/workspaces": {
                "sort": "id",
                "persistent-workspaces": {
                    "*": 5
                }
            },
            "hyprland/window": {
                "format": "{title} <small>{class}</small>",
                "max-length": 100,
                "separate-outputs": true
            },
            "cpu": {
                "interval": 1,
                "format": " {usage:02d}%",
                "format-alt": " {usage:02d}%: {avg_frequency:0.2f} / {max_frequency:0.2f} GHz"
            },
            "memory": {
                "interval": 15,
                "format": " {percentage:02d}%",
                "format-alt": " {percentage:02d}%: {used:0.1f} / {total:0.1f} GB"
            },
            "disk": {
                "interval": 90,
                "format": " {percentage_used:02d}%",
                "format-alt": " {percentage_used:02d}%: {specific_used:0.1f} / {specific_total:0.1f} GB used ({percentage_free:02d}% free)",
                "unit": "GB"
            },
            "hyprland/language": {
                "format": "<small>{}</small>"
            },
            "battery": {
                "format": "{capacity}% {icon}",
                "format-icons": [
                    "",
                    "",
                    "",
                    "",
                    ""
                ]
            },
            "clock": {
                "format": "{:%I:%M %p}",
                "format-alt": "{:%A, %B %d   %I:%M %p}"
            }
        },
        {
            "output": [ "!Samsung Electric Company LF32TU87 HCPRA08903", "!Acer Technologies B326HK T1NAA0038522", "!Chimei Innolux Corporation 0x1406", "!LG Electronics LG TV 0x01010101" ],
            "height": 28,
            "modules-left": [
                "hyprland/workspaces"
            ],
            "modules-center": [
                "hyprland/window"
            ],
            "modules-right": [
                "battery",
                "clock"
            ],

            "hyprland/workspaces": {
                "sort": "id",
                "persistent-workspaces": {
                    "*": 3
                }
            },

            "battery": {
                "format": "{capacity}% {icon}",
                "format-icons": [
                    "",
                    "",
                    "",
                    "",
                    ""
                ]
            },
            "clock": {
                "format": "{:%I:%M %p}",
                "format-alt": "{:%A, %B %d   %I:%M %p}"
            }
        }
    ]
  '';

  xdg.configFile."waybar/style.css".text = ''
    custom-power, * {
        min-height: 0;
        font-size: 12pt;
        font-family: sans-serif, monospace, "Font Awesome 6 Free";
    }

    #workspaces button.focused {
        background: #${col.base02};
        border-bottom: 3px solid #${col.base07};
    }

    #workspaces button {
        padding: 0 0.25rem;
        border: 0.25rem solid #${col.base01};
        background: transparent;
        color: #${col.base06};
    }

    #workspaces button:not(.empty),
    #workspaces button.active {
        color: #${col.base0B};
    }

    #workspaces button.special {
        color: #${col.base0E};
    }
    #workspaces button.visible {
        background-color: #${col.base02};
        color: #${col.base0D};
    }

    #workspaces button.urgent {
        color: #${col.base08};
    }

    #cpu,
    #disk,
    #memory,
    #workspaces * {
        font-size: 11pt;
        font-family: monospace, "Font Awesome 6 Free";
    }

    /* The bar */
    window#waybar {
        background: #${col.base01};
        color: #${col.base07};
    }

    label.module,
    #tray {
        border-bottom-width: 0.125rem;
        border-bottom-style: solid;
        padding: 0 0.625rem;
        margin: 0 0.125rem;
    }

    #bluetooth.disabled,
    #network.disabled {
        color: #${col.base08};
        border-color: #${col.base08};
    }

    #mpris.spotify,
    #mpris.spot {
        color: #${col.base0B};
    }

    #mpris.firefox,
    #mpris.vlc {
        color: #${col.base09};
    }

    #mpris.default {
        color: #${col.base0D};
    }

    #mpris.paused,
    #mpris.stopped {
        color: transparent;
        border-color: transparent;
    }

    #bluetooth.off,
    #network.disconnected,
    #wireplumber.muted {
        color: #${col.base05};
        border-color: #${col.base05};
    }

    label.module:hover /*, #tray > *:hover*/ {
        background-color: #${col.base02};
    }

    .modules-right > :nth-last-child(7) {
        border-bottom-color: rgba(${h2d col.base08}, 0.66);
        color: #${col.base08};
    }
    .modules-right > :nth-last-child(6) {
        border-bottom-color: rgba(${h2d col.base09}, 0.66);
        color: #${col.base09};
    }
    .modules-right > :nth-last-child(5) {
        border-bottom-color: rgba(${h2d col.base0A}, 0.66);
        color: #${col.base0A};
    }
    .modules-right > :nth-last-child(4) {
        border-bottom-color: rgba(${h2d col.base0B}, 0.66);
        color: #${col.base0B};
    }
    .modules-right > :nth-last-child(3) {
        border-bottom-color: rgba(${h2d col.base0C}, 0.66);
        color: #${col.base0C};
    }
    .modules-right > :nth-last-child(2),
    #tray {
        border-bottom-color: rgba(${h2d col.base0D}, 0.66);
        color: #${col.base0D};
    }
    .modules-right > :last-child {
        border-bottom-color: rgba(${h2d col.base0E}, 0.66);
        color: #${col.base0E};
    }

    /*
      .modules-left > :last-child {
        border-bottom-color: @peach;
        color: @peach;
      }
    */

    .modules-left > :first-child {
        border-bottom-color: rgba(${h2d col.base0B}, 0.66);
        color: #${col.base0B};
    }

    #battery {
        background-color: #ffffff;
        color: black;
    }

    #battery.charging {
        color: white;
        background-color: #${col.base0A};
    }

    @keyframes blink {
        to {
            background-color: #ffffff;
            color: black;
        }
    }

    #battery.warning:not(.charging) {
        background: #f53c3c;
        color: white;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: steps(12);
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    menu,
    tooltip {
        font-family: sans-serif;
        background: #${col.base03};
        color: @subtext0;
        border: 0.0625em solid rgba(${h2d col.base01}, 0.75);
        border-radius: 0.75em;
        margin: 0;
        padding: 0.25em;
    }
    menuitem {
        border: 0.0625em solid transparent;
        border-radius: calc(0.75em - (0.25em - 0.0625em));
    }
    menuitem:hover {
        border-color: #${col.base0B};
        background-color: @surface1;
        color: #${col.base07};
    }

    tooltip {
      background: rgba(${h2d col.base01}, 0.66);
    }
    tooltip label {
        color: #${col.base07};
    }

    #custom-spacer,
    #custom-spacer:hover {
        border-bottom: none;
        border-bottom-color: transparent;
        background-color: transparent;
    }
  '';
}
