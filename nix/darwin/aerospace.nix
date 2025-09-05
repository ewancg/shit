# this is a home manager module

{ ... }: {
  home = {
    packages = [ aerospace ];
    file.aerospace = {
      target = ".aerospace.toml";
      text = ''
        enable-normalization-flatten-containers = false
        enable-normalization-opposite-orientation-for-nested-containers = false

        ## borders
        after-startup-command = [
          'exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0'
        ]

        [gaps]
        inner.horizontal = 15
        inner.vertical   = 15
        outer.left       = 15
        outer.bottom     = 15
        outer.top        = 15
        outer.right      = 15

        [mode.main.binding]
        alt-j = 'focus down'
        alt-k = 'focus up'
        alt-l = 'focus right --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors'
        alt-h = 'focus left --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors'

        alt-shift-j = 'move down'
        alt-ctrl-j = 'move-node-to-monitor down'
        alt-shift-k = 'move up'
        alt-ctrl-k = 'move-node-to-monitor up'
        alt-shift-l = 'move right'
        alt-ctrl-l = 'move-node-to-monitor right'
        alt-shift-h = 'move left'
        alt-ctrl-h = 'move-node-to-monitor left'
        alt-shift-comma = 'move-workspace-to-display next'
        alt-shift-period = 'move-workspace-to-display next'
        alt-slash = 'layout tiles horizontal vertical'
        alt-comma = 'layout accordion horizontal vertical'
        alt-tab = 'workspace-back-and-forth'

        alt-enter = 'exec-and-forget /Applications/Alacritty.app/Contents/MacOS/alacritty'


        alt-b = 'split horizontal'
        alt-v = 'split vertical'

        alt-f = 'fullscreen'

        #alt-d = 'layout v_accordion' # 'layout stacking' in i3
        alt-d = 'layout h_accordion tiles' # 'layout tabbed' in i3
        #alt-e = 'layout tiles horizontal vertical' # 'layout toggle split' in i3

        alt-shift-space = 'layout floating tiling' # 'floating toggle' in i3

        alt-1 = 'summon-workspace 1'
        alt-2 = 'summon-workspace 2'
        alt-3 = 'summon-workspace 3'
        alt-4 = 'summon-workspace 4'
        alt-5 = 'summon-workspace 5'
        alt-6 = 'summon-workspace 6'
        alt-7 = 'summon-workspace 7'
        alt-8 = 'summon-workspace 8'
        alt-9 = 'summon-workspace 9'

        alt-shift-1 = 'move-node-to-workspace 1'
        alt-shift-2 = 'move-node-to-workspace 2'
        alt-shift-3 = 'move-node-to-workspace 3'
        alt-shift-4 = 'move-node-to-workspace 4'
        alt-shift-5 = 'move-node-to-workspace 5'
        alt-shift-6 = 'move-node-to-workspace 6'
        alt-shift-7 = 'move-node-to-workspace 8'
        alt-shift-8 = 'move-node-to-workspace 8'
        alt-shift-9 = 'move-node-to-workspace 9'
      '';
    };
  };
}
