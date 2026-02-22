{ config
, pkgs
, ...
}:
let
  col = config.lib.stylix.colors;
in
{
  home.packages = [
    pkgs.dunst
  ];

  xdg.configFile."dunst/dunstrc".text = ''
    [global]
    icon_path = ${pkgs.arc-icon-theme}/share/icons/Arc/panel/22/status/

    follow = mouse
    offset = (3, 3)
    width = (200, 600)
    height = (75, 120)

    font = "Sans Serif 11"
    corner_radius = 8
    frame_width = 2
    progress_bar_corner_radius = 2
    progress_bar_frame_width = 1

    icon_corner_radius = 4
    min_icon_size = 64
    max_icon_size = 64

    enable_recursive_icon_lookup = true
    idle_threshold = 1m
    separator_color= "#${col.base03}"

    [urgency_low]
    background = "#${col.base01}"
    foreground = "#${col.base06}"
    frame_color = "#${col.base0B}"
    timeout = 3s

    [urgency_normal]
    background = "#${col.base01}"
    foreground = "#${col.base07}"
    frame_color = "#${col.base0D}"
    timeout = 10s

    [urgency_critical]
    background = "#${col.base01}"
    foreground = "#${col.base07}"
    frame_color = "#${col.base08}"
    timeout = 0s
  '';

}
