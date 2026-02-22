{ config
, pkgs
, commands
, root
, style
, ...
}:
let
  prefix = "util-script-";
  mkScripts = builtins.mapAttrs (name: value: pkgs.writeShellScriptBin "${prefix}${name}" value);
  scripts =
    let
      declare_slurp_args = ''export SLURP_ARGS="-d -w 2 -B #00000044 -b #00000044 -s #00000011 -c #$_SLURP_HIGHLIGHT"'';
    in
    with commands;
    mkScripts rec {
      network-event = ''
        printf "%s" "network event idk" $@
      '';
      teamspeak-toggle-mute = let ts3conn = "localhost 25639"; auth = "auth apikey=UNT2-9P4L-LD9K-CHSZ-IIM4-RK2P"; in ''
        PROBE_CMDS="
        ${auth}
        whoami"

        RESPONSE=$(echo -e "$PROBE_CMDS" | ${nc} -w 2 ${ts3conn} 2>&1)
        if [ $? -ne 0 ]; then
            echo "Error: Cannot connect to TeamSpeak" >&2
            echo "Make sure TeamSpeak is running and ClientQuery plugin is enabled" >&2
            exit 1
        fi

        CURRENT_MUTE=$(echo "$RESPONSE" | grep -oP 'client_input_muted=\K[0-9]+' | head -1)
        if [ -z "$CURRENT_MUTE" ]; then
            echo "Error: Could not determine current mute status" >&2
            echo "$RESPONSE" >&2
            exit 1
        fi

        NEW_MUTE=$(["$CURRENT_MUTE" = "1"] && return 0 || return 1)
        TOGGLE_CMDS="
        ${auth}
        clientupdate client_input_muted=$NEW_MUTE
        quit"

        RESPONSE=$(echo -e "$PROBE_CMDS" | ${nc} -w 2 ${ts3conn} 2>&1)
        if echo "$RESPONSE" | grep -q "error id=0"; then
            exit 0
        else
            echo "$RESPONSE" >&2
            exit 1
        fi
      '';
      eww-display-countdown = ''
        # expects envvar start with timestamp in the future
        # e.g. start=$(expr $(date +%s) + 5)
        if [ "$1" == "-c" ]; then # current time only
          printf "$(${date} -u -d @$(( $start - `${date} +%s` )) +%H:%M:%S)"
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

        ${hyprctl} dispatch workspace 6
        ${hyprctl} dispatch workspace 1
      '';
      # $1; input (bytes)
      get-readable-filesize = ''
        ${numfmt} --to=iec-i --suffix=B --format="%.1f" "$1"
      '';
      # $1; source directory
      # $2; list of extensions to filter by
      # $3; list of patterns to exclude by
      # $4; maximum lines (default 1)
      get-newest-media = ''
        extensions="''${2:+( $(for i in $2; do s="-name \*.$i"; [ "$i" != "$(printf "$2" | ${awk} '{print $1;}')" ] && printf "%s %s " -o $s || printf "%s " $s; done) )}"
        exclusions="''${3:+( $(for i in $3; do s="! -wholename \*$i\*"; printf "%s " $s; done))}"
        args="`${realpath} $1` -type f $extensions $exclusions -exec ls -1t {} +"
        ${find} $args | ${commands.sort} -n | ${cut} -d' ' -f 2- | ${commands.tail} -n ''${4:-1}
      '';
      # $1; source directory
      upload-newest-media = ''
        juush_in="$(${script "get-newest-media"} "$1")"
        [ -z "$juush_in" ] && ${notify-send} "Media upload error" "No files in '$1' to upload" && exit
        media_id=$(basename $juush_in)
        ${dunstify} -h string:x-canonical-private-synchronous:"$media_id" "Uploading media..." "\n$media_id" -t 0
        juush_out="$(${root + /dot/local/bin/juush} "$juush_in")"
        status=$?
        [ -z "$juush_out" ] && ${notify-send} -h string:x-canonical-private-synchronous:"$media_id" "Media upload error" "juush exited with code $status and did not return a link" && exit
        result=$(${dunstify} -h string:x-canonical-private-synchronous:"$media_id" "Media upload complete (click to copy)" "$(printf "%s\n%s" "$juush_out" "$media_id")" -A copy,Copy)
        [ ! -z "$result" ] && [ $result -eq 2 ] && printf "$juush_out" | ${wl-copy}
      '';
      # $1; capture type
      # $2; file type (optional)
      media-filename = ''
        td="$(${date} "+%d.%m.%y-%H.%M.%S")"
        # time-based short uid which is more granular than 1 second
        uid="$(${uuidgen} -7 | ${xxhsum} -H0 --binary --quiet | ${awk} '{print $1}')"
        printf "%s_%s_%s%s" "$1" "$td" "$uid" "''${2:+.$2}"
      '';
      # $1; select type
      # $2; output directory
      capture-image = ''
        fname="$(${script "media-filename"} "$1" "png")"
        ${declare_slurp_args}
        ${commands.grimblast} -t png -f copysave $1 -o "$2/$fname" && ${notify-send} -t 2000 "Screenshot saved" "$fname"
      '';
      begin-video-capture = ''
        # remove ":active" and such from recording subjects
        prefix="$(printf "$1" | ${cut} -d: -f1)"
        fname="$(${script "media-filename"} "$prefix")"

        printf "$fname" > "$video_id_path"
        printf "$2/$fname.mp4" > "$video_out_path"

        ${notify-send} -t 750 "Recording started" "Capturing active $prefix"

        ${declare_slurp_args}
        ${root + /dot/local/bin/hyprcap} record -s "$1" -o "$2" -f "$fname.mp4" -N
      '';
      end-video-capture = ''
        [ -z "$video_id_path" ] || [ -z "$video_out_path" ] && notify-send "Recording error" "No current recording to stop" && exit
        video_id="$(< "$video_id_path")"
        video_path="$(< "$video_out_path")"

        notify-send -h string:x-canonical-private-synchronous:"$video_id" "Stopping recording..." -t 0

        ${root + /dot/local/bin/hyprcap} record-stop

        function iter_probe {
          # ${ffprobe} -v quiet -of default=noprint_wrappers=1 "$@" | ${tr} "=" " "
          output="$(''${ffprobe} -v error -of default=noprint_wrappers=1 "$@" | ${tr} "=" " ")"
          notify-send "ffprobe" "$output"
          exit_code=$?
          [ $exit_code -ne 0 ] && echo "ffprobe failed with exit code $exit_code" >&2
          echo "$output"
        }

        function read_probe {
          _key=
          for i in $1; do
            if [ -z "$_key" ]; then
              _key="$i"
            else
              export "$2_''${_key}"="$i"
              _key=
            fi
          done
        }

        notify-send "probin" "$(${ffprobe} -version)"

        read_probe "$(iter_probe -i "$video_path" -show_entries format=duration,size,bit_rate -sexagecimal)" "file"
        read_probe "$(iter_probe -i "$video_path" -select_streams v:0 -show_entries stream=codec_name,bit_rate)" "video"
        read_probe "$(iter_probe -i "$video_path" -select_streams a:0 -show_entries stream=codec_name,bit_rate)" "audio"

        if [ -z "$video_codec_name" ]; then
          video_info="Unable to get video info"
        else
          video_info="$(printf \
            "%s\n%s | %s | %s/%s \n%s (%s/%s)" \
            "$(printf "$file_duration" | ${awk} -F. '{ after=substr($2,1,2); print $1 "." after }')" "$(${script "get-readable-filesize"} "$file_size")" "$video_codec_name" "$audio_codec_name" \
            "$(${script "get-readable-filesize"} "$file_bit_rate")/s" \
            "$(${script "get-readable-filesize"} "$video_bit_rate")" \
            "$(${script "get-readable-filesize"} "$audio_bit_rate")"
          )"
        fi

        ${notify-send} -h string:x-canonical-private-synchronous:"$video_id" "Recording stopped" "$(basename "$video_path")\n$video_info"

        for i in "$video_id_path" "$video_out_path"; do
          [ -e "$i" ] && rm "$i"
        done
      '';
      # $1; select type
      # $2; output directory
      capture-video = ''
        export hyprcap_pid_file="''${XDG_RUNTIME_DIR:-/run}/hyprcap_rec.pid"
        export video_id_path="''${XDG_RUNTIME_DIR:-/run}/hyprcap_rec_id"
        export video_out_path="''${XDG_RUNTIME_DIR:-/run}/hyprcap_rec_out"

        # A recording is in-progress
        if [ -r "$hyprcap_pid_file" ]; then
          ${script "end-video-capture"}
        else
          export WFR_ACODEC"libopus"
          export WFR_VCODEC="av1_nvenc"
          export WFR_CODEC_OPTS="preset=17 tune=hq multipass=2 highbitdepth=true"
          ${declare_slurp_args}
          ${script "begin-video-capture"} "$@"
        fi
      '';
      # $1; output directory
      capture-text = ''
        fname=$(${script "media-filename"} "ocr")
        imgname="$fname.png"
        ${declare_slurp_args}
        ${commands.grimblast} save area -o "$1/$imgname" -f
        OUTPUT="$(${tesseract} "$1/$imgname" - -l eng)"
        printf "%s" "$OUTPUT" | ${tee} "$1/$fname.txt" | ${wl-copy} && ${notify-send} -t 2000 "Text capture saved" "$(printf "%s\nText copied to clipboard" "$fname")"
      '';
    };
  script = (name: "${(scripts.${name}.out)}/bin/${prefix}${name}");
in
{
  inherit scripts script;
}
