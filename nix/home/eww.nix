{ config
, pkgs
, util
, ...
}:
let
  col = config.lib.stylix.colors;
  h2d = util.style.hexColorToDecimalTriplet;
in
{
  home.packages = [
    pkgs.eww
  ];

  xdg.configFile."eww/eww.yuck".text = with util.commands; ''
    (defpoll current-volume
      :initial 50
      :interval "0.1s"
      :run-while time-visible   ; optional, defaults to 'true'
      "${gojq} -n \"$(${wpctl} get-volume @DEFAULT_SINK@ | ${cut} -b 9-) * 100\"" ; 9 - "Volume: "
    )

    (defwindow volume [screen x]
      :id "volume"
      :monitor screen
      :geometry (geometry :x x
                          :y "8px"
                          :width "192px"
                          :height "64px"
                          :anchor "top left")
      :stacking "overlay"
      :exclusive false
      :focusable false
      :wm-ignore false
      (box
        :class "volume-container"
        :orientation "horizontal"
        :spacing 2
        (scale
          :value current-volume
          :min 0
          :max 101
          :round-digits 0
          :onchange "${wpctl} set-volume @DEFAULT_SINK@ {}%"
        )
      )
    )

    (defwindow overlay [screen]
      :id "overlay"
      :monitor screen
      :geometry (geometry :x "0px"
                          :y "0px"
                          :width "100%"
                          :height "100%"
                          :anchor "bottom center")
      :namespace "overlay"
      :wm-ignore true
      :exclusive false
      :focusable false
      (box)
    )

    (defwindow calendar [screen]
      :id "calendar"
      :monitor screen
      :geometry (geometry :x "2px"
                          :y "2px"
                          :width "15%"
                          :height "15%"
                          :anchor "top right")
      :stacking "overlay"
      :exclusive false
      :focusable false
      :wm-ignore false
      (calendar)
    )

    (defwindow backdrop [screen]
      :id "backdrop"
      :monitor screen
      :geometry (geometry :x "0px"
                          :y "0px"
                          :width "100%"
                          :height "100%"
                          :anchor "bottom center")
      :stacking "overlay"
      :namespace "overlay"
      :focusable false
      :exclusive false
      :wm-ignore false
      (eventbox :onclick "${eww} close-all")
    )

    (defpoll timer
                  :initial ``
                  :interval "1s"
                  :run-while time-visible   ; optional, defaults to 'true'
                  "${cat} /tmp/timeout-timer"
    ;  `${cat} /tmp/timeout-timer | head -n 1`
    )

    (defwindow prompt [screen verb uid]
      :monitor screen
      :id uid
      :geometry (geometry :x "0px"
                          :y "0px"
                          :width "288px"
                          :height "80px"
                          :anchor "center")
      :stacking "overlay"
      :exclusive false
      :focusable false
      :wm-ignore false
      (box :class "prompt-container"
           :orientation "vertical"
           :spacing 0
           :space-evenly false
        (label :vexpand true
          :text "System will ''${verb} in ''${timer} seconds.")
        (box :class "prompt-buttons hbuttonbox"
             :orientation "horizontal"
             :spacing 0
             :space-evenly true
             :vexpand false
             (button :class "accept"
                     :onclick "${eww} close-all; systemctl ''${verb}" "Confirm")
             (button :class "deny"
             :onclick "${eww} close-all" "Cancel")
        )
      )
    )

    (defwidget power-menu-buttons []
      (box :class "power-button-container vbuttonbox"
           :orientation "vertical"
           :spacing 0
        (button :onclick "${util.script "eww-powermenu-wrapper"} suspend" "Suspend")
        (button :onclick "${util.script "eww-powermenu-wrapper"} poweroff" "Shutdown")
        (button :onclick "${util.script "eww-powermenu-wrapper"} reboot " "Reboot")
    ))

    (defwindow power-menu [screen]
      :id "power-menu"
      :monitor screen
      :geometry (geometry :x "8px"
                          :y "8px"
                          :width "192px"
                          :height "144px"
                          :anchor "top left")
      :stacking "overlay"
      :exclusive false
      :focusable false
      :wm-ignore false
      (power-menu-buttons)
    )
  '';

  xdg.configFile."eww/eww.scss".text = ''
    .backdrop {
        background-color: rgba(0,0,0,0.25);
    }

    .overlay {
        background-color: rgba(0,0,0,1);
    }

    .prompt, .volume, .power-menu {
        background-color: transparent;
        background: none;
        margin: 0.125em;
        border-radius: 0.75em;
    }
    .prompt > *, .volume > *, .power-menu > * {
        background-color: #${col.base01};
        border-radius: 0;
    }

    *:not(button) > label {
        margin: 0;
        padding: 1em 2em;
        color: #${col.base06};
    }

    button {
        padding: 0.325em 0.6em;
        background-color: #${col.base01};
        border: 0.5pt solid rgba(${h2d col.base03}, 0.5);
        color: #${col.base05};
    }

    button:hover {
        background-color: #${col.base02};
        color: #${col.base07};
    }

    button.accept {
        color: #${col.base08};
    }

    .volume > scale trough highlight {
        background-color: #${col.base0A};
        color: #${col.base0A};
    }

    .volume > * {
        margin: 0;
        padding: 0.25em 1.5em;
        border-radius: calc(0.75em - 0.1875em);
    }


    .prompt > label {
        background-color: #${col.base00};
    }
    .prompt > *:first-child {
        border-top-left-radius:  (0.75em - 0.125em);
        border-top-right-radius: (0.75em - 0.125em);
    }
    .prompt > *:last-child {
        border-bottom-left-radius: (0.75em - 0.125em);
        border-bottom-right-radius:(0.75em - 0.125em);
    }

    .volume-container, .power-button-container, .prompt-container {
        background-color: #${col.base01};
        border-radius: 0.75em;
        margin: 0.125em;

        border: 0.1875em solid #${col.base0A};
        box-shadow: 0 0 0 0.0625em rgba(${h2d col.base01}, 0.5);
    }

    .power-button-container, .prompt-container {
        border-color: #${col.base0B};
    }

    .power-button-container > * {
        padding: 0;
        border: 0.5pt solid rgba(${h2d col.base03}, 0.5);
        border-left: none;
        border-right: none;
    }
    .power-button-container > *:first-child {
        border-top-left-radius:  calc(0.75em - 0.125em);
        border-top-right-radius: calc(0.75em - 0.125em);
        border-top: none;
    }
    .power-button-container > *:last-child {
        border-bottom-left-radius: calc(0.75em - 0.125em);
        border-bottom-right-radius: calc(0.75em - 0.125em);
        border-bottom: none;
    }

    .prompt-buttons, .prompt-buttons * {
        margin: 0;
        border-radius: 0px;
    }
    .prompt-buttons > *:first-child {
        border-bottom-left-radius: calc(0.75em - 0.125em);
    }
    .prompt-buttons > *:last-child {
        border-bottom-right-radius: calc(0.75em - 0.125em);
    }
  '';

}
