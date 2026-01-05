# home/base.nix; home config for all users (terminal, cli utilities, dev env...)

{
  config,
  pkgs,
  util,
  ...
}:
with pkgs;
let
  col = config.lib.stylix.colors;
in
{
  xdg.configFile.alacritty = {
    source = ../../dot/config/alacritty;
    recursive = true;
  };

  home = {
    stateVersion = "24.05";

    packages = [
      # cli tools
      atuin
      python3
      (pkgs.ffmpeg-full.override { withUnfree = true; })
      bchunk
      choose
      datamash
      fastfetch
      file
      gojq

      killall
      p7zip
      unzip
      unrar

      # virt

      # Nix
      direnv
      nil
      nix-index
      nixpkgs-fmt

      # Essential libraries and utilities
      git
      github-cli
      gnupg
      wget

      fish
      tmux
      fd
      fzf
      tree

      # Whatever
      imagemagick

      # Not Windows fonts
      corefonts
      fira-code
      fira-code-symbols
      liberation_ttf
      jetbrains-mono
      mplus-outline-fonts.githubRelease
      noto-fonts
      open-sans
      ubuntu-sans-mono
      ubuntu-classic
      ucs-fonts
      vista-fonts
      zilla-slab

      nerd-fonts.jetbrains-mono

      # Conflict
      # proggyfonts
      # broke 11/23
      #dina-font
    ]
    ++ (with fishPlugins; [
      z # common directories
      bass # source bash stuff
      fzf-fish # ctrl j file search
      async-prompt # yep
      autopair # add/remove paired delimeters automatically; e.g. (), [], {}, "", ''
      clownfish # "mock" command
      pure # prompt
    ]) ++ (builtins.attrValues util.scripts);

    sessionVariables = {
      EDITOR = "zeditor --new";
    };

    file = {
      # todo: link scripts
      ".local/bin" = {
        recursive = true;
        source = ../../dot/local/bin;
      };
      ".config/alacritty/_active.toml" = {
        source = ../../dot/config/alacritty/gruvbox-material-hard-light.toml;
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = "tmux";
      general.live_config_reload = true;

      window = (
        pkgs.lib.mkForce {
          dynamic_title = true;
          dimensions = {
            columns = 130;
            lines = 28;
          };
          decorations = "Full";
          opacity = 0.5;
          level = "AlwaysOnTop";
          resize_increments = true;
        }
      );

      # Handled by tmux
      scrolling.history = 0;

      cursor = {
        style = {
          shape = "Beam";
          blinking = "Off";
        };
        blink_interval = 500;
        thickness = 0.1;
      };

      font = (
        pkgs.lib.mkForce {
          normal = {
            family = "JetBrainsMono NerdFont Propo";
            style = "Light";
          };
          bold = {
            family = "JetBrainsMono NerdFont Propo";
            style = "Semibold";
          };
          italic = {
            family = "JetBrainsMono NerdFont Propo";
            style = "Regular Italic";
          };
          bold_italic = {
            family = "JetBrainsMono NerdFont Propo";
            style = "Semibold Italic";
          };
          size = 9.5625;
        }
      );

      mouse.bindings = [
        {
          mouse = "Right";
          mods = "None";
          action = "Copy";
        }
      ];

      keyboard.bindings = [
        {
          key = "Alt";
          mods = "Control";
          chars = ''\uE000'';
        }
      ];
    };
  };

  programs.nix-index.enableFishIntegration = true;

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      inline_height = "0";
      #key_path = "${config.home.homeDirectory}/secrets/ATUIN_KEY";
      ctrl_n_shortcuts = true;
      enter_accept = true;
      filter_mode = "session";
    };
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source

      set -x pure_enable_nixdevshell true
      set -x pure_symbol_nixdevshell_prefix '󱄅 '

      # too clunky
      set -x pure_enable_k8s false
      set -x pure_symbol_k8s_prefix ' '

      set -x pure_enable_aws_profile true

      set -x pure_symbol_git_stash 'stash'
      set -x PURE_GIT_DOWN_ARROW '↓'
      set -x PURE_GIT_UP_ARROW '↑'
      set -x pure_symbol_reverse_prompt '<><'
      set -x pure_symbol_prompt '><>'
      set -x pure_enable_single_line_prompt true
      set --universal pure_check_for_new_release false

      set -x pure_shorten_prompt_current_directory_length 1

      set -x FZF_DEFAULT_COMMAND "fdfind . $HOME"
      set -x FZF_LEGACY_KEYBINDS 0
      set -x FZF_COMPLETE 1

      set -U fish_greeting

      function poll
        string match -q "*y*" "$(printf "%s\n%s" "y" "N" | fzf --header "$1" --print-query)"
      end

      # scheme-based cargo shortcuts

      alias crun "RUST_LOG=debug cargo r --"
      alias crelease "RUST_LOG=info cargo r --release --"
      alias cb "cargo build"
      alias ct "cargo test"

      alias sqlxp "cargo sqlx prepare"
      alias sqlxdd "sqlx database drop"
      alias sqlxds "sqlx database setup"
      alias sqlxreset 'poll "Clear database at \'$DATABASE_URL\' and prepare queries?" && echo 'y' | sqlxdd  && sqlxds && sqlxp'

      alias llvmc "cargo llvm-cov"

      # scheme-based git shortcuts
      alias gpush "git push"
      alias gpull "git pull"
      alias gc "git commit"
      alias ga "git add"
      alias grm "git rm"
      alias grmf 'poll "Force remove $argv?" git rm -rf'
      alias gcam "git commit -am"
      alias gri "git rebase -i"
      alias grh 'poll "Hard reset?" && git reset --hard'

      function ghpr
        set -l args
        set index (contains --index -- -d $argv)
        if [ $status -eq 0 ]
          set -a args "--draft"
          set -e argv[$index]
        end
        set idx (contains --index -- -b $argv)
        if [ $status -eq 0 ]
          set body_idx (math $idx + 1)
          if [ $body_idx -le $(count $argv) ]
            set -a args "--body"
            set -a args "$argv[$body_idx]"
            set -e argv[$idx]
            set -e argv[$idx]
          else
            set_color yellow
            echo "-b provided without body"
            return
          end
        end
        gh pr create -f $argv $args
      end
      function ghc
        git clone "https://github.com/$argv[1]" $argv[2..-1]
      end
      function orgc
        ghc "discovery-digital/$argv[1]" $argv[2..-1]
      end
    '';
    functions = {
      nixbuildconf.body = ''
        set _nix_dist_rebuild "$([ $(uname) = 'Darwin' ] &&
          printf darwin-rebuild ||
          printf nixos-rebuild)";
        $_nix_dist_rebuild --flake ~/shit/#$hostname switch $argv'';

      nixpkg.body = ''NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixos."$1"'';

      bk.body = ''
        mv "$1" "$1.old"
      '';

      start.body = ''
        set _dist_start "$([ $(uname) = 'Darwin' ] &&
          printf open ||
          printf xdg-open)";
        $_dist_start $argv
      '';

      kc.body = ''
        set -f new_env (kubectl config get-contexts -o name | fzf)
        if test "A$new_env" = "A"
            exit 1
        end
        kubectl config use-context $new_env
      '';

      envsource.body = ''
        set -f envfile "$argv"
        if not test -f "$envfile"
            echo "Unable to load $envfile"
            return 1
        end
        while read line
            if not string match -qr '^#|^$' "$line" # skip empty lines and comments
                if string match -qr '=' "$line" # if `=` in line assume we are setting variable.
                    set item (string split -m 1 '=' $line)
                    set item[2] (eval echo $item[2]) # expand any variables in the value
                    set -gx $item[1] $item[2]
                    echo "Exported key: $item[1]" # could say with $item[2] but that might be a secret
                else
                    eval $line # allow for simple commands to be run e.g. cd dir/mamba activate env
                end
            end
        end < "$envfile"
      '';
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = with col.withHashtag; ''
      unbind C-b
      set -g prefix 
      set -g escape-time 1
      set -g mouse on
      set -ga terminal-features "*:hyperlinks".

      bind h split-window -h
      bind v split-window -v

      bind r source-file ~/.config/tmux/tmux.conf

      # default statusbar colors
      set-option -g status-left "[#{session_id}/#{window_id}] "
      set-option -g status-style "fg=${base04},bg=${base00}"

      # default window title colors
      set-window-option -g window-status-format "[#I:#W#{?window_flags,#{window_flags}, }]"
      set-window-option -g window-status-style "fg=${base05},bg=${base02}"

      # active window title colors
      set-window-option -g window-status-current-format "[#I:#W#{?window_flags,#{window_flags}, }]"
      set-window-option -g window-status-current-style "fg=${base14},bg=${base01}"

      # pane border
      set-option -g pane-border-style "fg=${base03}"
      set-option -g pane-active-border-style "fg=${base05}"

      # message text
      set-option -g message-style "fg=${base07},bg=${base03}"

      # pane number display
      set-option -g display-panes-active-colour "${base0D}"
      set-option -g display-panes-colour "${base05}"

      # clock
      set-window-option -g clock-mode-colour "${base0C}"

      # copy mode highligh
      # set-window-option -g mode-style "fg=#bdae93,bg=#504945"

      # bell
      # set-window-option -g window-status-bell-style "fg=#3c3836,bg=#fb4934"
    '';
    plugins = with tmuxPlugins; [
      sensible
      # gruvbox
      battery # seeing battery in remote session
      continuum # tmux session restore
      # vim-tmux-navigator
    ];
  };
}
