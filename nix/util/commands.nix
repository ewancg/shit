{ pkgs, ... }:
let
  mkCoreutils = list: pkgs.lib.genAttrs list (name: "${pkgs.coreutils-full}/bin/${name}");
  mkCommandBindings = attrs: pkgs.lib.mapAttrs (name: pkg: "${pkg}/bin/${name}") attrs;
in
(mkCoreutils [
  "cat"
  "cut"
  "date"
  "expr"
  "head"
  "nohup"
  "numfmt"
  "realpath"
  "rm"
  "sleep"
  "sort"
  "tail"
  "tee"
  "tr"
])
  // (
  with pkgs;
  mkCommandBindings {
    inherit (pkgs)
      datamash
      eww
      grimblast
      playerctl
      gojq
      tailscale
      tesseract
      ;

    # datamash = datamash;
    # eww = eww;
    # grimblast = grimblast;
    # playerctl = playerctl;
    # gojq = gojq;
    # tesseract = tesseract;

    sh = dash;
    awk = gawk;
    dunstify = dunst;
    ffprobe = ffmpeg;
    find = findutils; # replace with fd?
    grep = gnugrep;
    hyprctl = hyprland;
    pgrep = procps;
    nc = busybox;
    notify-send = libnotify;
    uuidgen = util-linux;
    wpctl = wireplumber;
    wl-copy = wl-clipboard-rs;
    wl-paste = wl-clipboard-rs;
    xxhsum = xxHash;
  }
)
