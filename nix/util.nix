{ pkgs, secrets, ... }:
with pkgs;
rec {
  ## Functions
  ## --------------------

  ## Create a hashed password file in the store from its text
  password = user: builtins.toString (pkgs.writeText "_${user}" secrets.hashedPasswords.${user});

  ## Briefly get the store path to a utility script
  script = name: "${(scripts.${name}.out)}/bin/${utilScriptStorePrefix}${name}";

  ## Convert 1 byte of hex into its decimal representation
  hexToDecimal =
    hex:
    let
      hexMap = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
      firstDigit = hexMap.${builtins.substring 0 1 hex};
      secondDigit = hexMap.${builtins.substring 1 1 hex};
    in
    16 * firstDigit + secondDigit;

  # Convert 3 bytes of hex info denoting a 24 bit color into each value's decimal form (`r,g,b`)
  hexColorToDecimalTriplet =
    hex:
    let
      r = hexToDecimal (builtins.substring 0 2 hex);
      g = hexToDecimal (builtins.substring 2 4 hex);
      b = hexToDecimal (builtins.substring 4 6 hex);
    in
    "${toString r},${toString g},${toString b}";

  ## Definitions
  ## --------------------

  ## `with util.commands;` to refer to executables absolutely without typing it or using lib.getExe
  commands = {
    awk = "${gawk}/bin/awk";
    cat = "${coreutils-full}/bin/cat";
    cut = "${coreutils-full}/bin/cut";
    datamash = "${datamash}/bin/datamash";
    date = "${coreutils-full}/bin/date";
    dunstify = "${dunst}/bin/dunstify";
    eww = "${eww}/bin/eww";
    expr = "${coreutils-full}/bin/expr";
    grep = "${gnugrep}/bin/grep";
    hyprctl = "${hyprland}/bin/hyprctl";
    gojq = "${gojq}/bin/gojq";
    notify-send = "${libnotify}/bin/notify-send";
    nohup = "${coreutils-full}/bin/nohup";
    rm = "${coreutils-full}/bin/rm";
    sleep = "${coreutils-full}/bin/sleep";
    uuidgen = "${util-linux}/bin/uuidgen";
    wpctl = "${wireplumber}/bin/wpctl";
  };

  ## Special script definition area. Paths to these scripts should be retrieved with util.script "name"
  scripts =
    with commands;
    builtins.mapAttrs (name: value: pkgs.writeShellScriptBin "${utilScriptStorePrefix}${name}" value) {
      network-event = ''
        echo todo
      '';
      eww-display-countdown = ''
        # expects envvar start with timestamp in the future
        # e.g. start=$(expr $(date +%s) + 5)
        if [ "$1" == "-c" ]; then # current time only
          echo "$(${date} -u -d @$(( $start - `${date} +%s` )) +%H:%M:%S)"
          exit
        fi
        while (( "$start" >= "`${date} +%s`" )); do # show time until timeout
          time="$(( "$start" - "`${date} +%s`" ))"
          printf '%s' "$(date -u -d "@$time" +%s)" > "$1"
          ${sleep} 1
        done
      '';
      eww-powermenu-wrapper = ''
        function show_backdrop {
        for i in $(seq 0 $(expr `${hyprctl} -j monitors | ${gojq} -r length` - 1)); do {
              export model="$(${hyprctl} -j monitors | ${gojq} -r "first(.[$i]) | .model")"
              ${eww} open backdrop --screen="$model" --id="$i" &
          }
          done
        }

        case $1 in
          "suspend")
            ;&
          "poweroff")
            ;&
          "reboot")
            timeout=10
            verb="$1"
            start="$(${expr} $(${date} +%s) + $timeout)"

            ${eww} close-all

            show_backdrop
            export outfile="/tmp/timeout-timer"
            ${rm} -rf "$outfile"

            export start
            ${script "eww-display-countdown"} "$outfile" &
            ${script "eww-toggle-window"} prompt "--arg uid=$(${uuidgen}) --arg verb=$verb" default
            ${script "eww-timeout-event"} "$verb" "$timeout" &
            ;;
          *)
            ${notify-send} "Unknown parameter"
            ;;
        esac
      '';

      eww-timeout-event = ''
        # $1 verb (suspend, reboot, poweroff), $2 timeout
        _id="$(${eww} active-windows | ${grep} prompt | ${awk} '{print $1-1}')"
        ${sleep} "$2"
        _new_id="$(${eww} active-windows | ${grep} prompt | ${awk} '{print $1-1}')"
        ${notify-send} "$0" "old id: ''${_id}\nnew id: ''${_new_id}"
        if [ "$_id" != "" ] && [ "$_id" == "$_new_id" ]; then
            systemctl "$1"
            ${notify-send} "" "'systemctl $1' executed at `${date}`"
            ${eww} close-all
        else
            ${notify-send} -u low "$1 cancelled"
        fi
      '';
      eww-toggle-window = ''
        # $1 = window name, $2 arguments, $3 = monitor id or "default" (or none) for current
        ${eww} active-windows | ${grep} "$1" > /dev/null
        if [ $? -eq 0 ]; then
            ${eww} close "$1"
        else
            if [ "$3" == "default" ]; then
              _screen="$(${hyprctl} -j monitors | ${gojq} -r 'first(.[] | select(.focused)) | .model')"
            else
              _screen="$3"
            fi
            ${eww} open "$1" --screen="$_screen" $2
        fi
      '';

      dunst-status-change = ''
        # $1 mode $2 direction
        msg_tag="dunst-status-change"

        audio_device="@DEFAULT_AUDIO_SINK@"
        volume_step="0.05" # / 1.0

        function todo {
            ${notify-send} "Todo"
            exit
        }

        function volume-notify {
            # $1 volume
            display_volume="$(${gojq} -n "$1 * 100" | ${awk} '{printf "%.0f", $1}')"

            ${dunstify} -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:"$msg_tag" \
            -h string:hlcolor:"$(get-color 07)" \
            -h int:value:"$display_volume" "vol: $display_volume% $2"
            exitreturn
        }

        case "$1" in
          "volume")
            base="$(${wpctl} get-volume "$audio_device")"

            printf "$base" | ${grep} "[MUTED]"
            is_unmuted=$?

            export current_volume="$(printf "$base" | ${awk} '{print $2}')"

            operation=
            [ "$2" == "up" ] && operation="$volume_step"
            [ "$2" == "down" ] && operation="-$volume_step"

            expected_volume="$(printf "%s\n" "$(${gojq} -n "$current_volume + $operation")" "1.0" | ${datamash} min 1)"
            if [ "$is_unmuted" == "1" ] && [ "$(${gojq} -n "$expected_volume >= 0.0")" == "true" ]; then
                if [ "$2" != "" ] && [ "$2" != "mute" ]; then
                    ${wpctl} set-volume "$audio_device" "$expected_volume"
                fi
                volume-notify "$expected_volume"
                exit
            else
                if [ "$2" == "mute" ]; then
                    ${wpctl} set-mute "$audio_device" "$is_unmuted"
                    if [ "$is_unmuted" == "0" ]; then
                        volume-notify "$current_volume" "(unmuted)"
                        exit
                    fi
                fi
                ${dunstify} -a "changeVolume" -u low -i audio-volume-muted -h string:x-dunst-stack-tag:"$msgTag" "muted"
            fi
            ;;
          "brightness")
            todo
            ;;
        esac
      '';
      reset-window-position = ''
        # $1: unique window descriptor, $2: workspace id
        # hyprctl dispatch focuswindow "class:^(vesktop)\$"; hyprctl dispatch movetoworkspace "special:magic"

        while [ "$_lock" = true ]; do
          :
        done

        export _lock true
        ${hyprctl} dispatch focuswindow "class:^($1)\$"
        export _elapsed=false
        ${nohup} sleep 3 & export _elapsed=true >/dev/null 2>&1
        while [ "$(${hyprctl} activewindow -j | ${gojq} -r .class)" != "$1" ]; do
          :
        done
        ${hyprctl} dispatch movetoworkspace "$2"
        export _lock false
      '';
      reset-window-positions = ''
        ${script "reset-window-position"} "vesktop" "special:magic"
        ${script "reset-window-position"} "ts3client" "special:magic"
        ${script "reset-window-position"} "spotify" "special:magic"

        ${script "reset-window-position"} "firefox" 1
        ${script "reset-window-position"} "thunderbird" 2

        hyprctl dispatch workspace 6
        hyprctl dispatch workspace 1
      '';
    };
  utilScriptStorePrefix = "__util-script-";
  graalvm-ce = pkgs.graalvm-ce;

  jdks =
    let
      override = (
        pname:
        pname.override {
          enableJavaFX = true;
          openjfx_jdk = pkgs.openjfx.override { withWebKit = true; };
        }
      );
    in
    [
      (override openjdk)
      # (override jdk24)
      (override jdk17)
      (override jdk24_headless)
      graalvm-ce
      temurin-bin-24
      temurin-bin-21
      temurin-bin-8
      temurin-bin-17
    ];

}
