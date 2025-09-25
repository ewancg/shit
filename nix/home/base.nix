# home/base.nix; home config for all users (terminal, cli utilities, dev env...)

{ pkgs, util, ... }:
with pkgs;
{
  home = {
    stateVersion = "24.05";

    packages = [
      # cli tools
      atuin
      python3
      ffmpeg
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
      gnupg
      wget

      alacritty
      fish
      tmux
      fd
      fzf
      tree

      # Whatever
      neovim
      imagemagick
      nethogs

      # Not Windows fonts
      corefonts
      fira-code
      fira-code-symbols
      liberation_ttf
      mplus-outline-fonts.githubRelease
      noto-fonts
      open-sans
      ubuntu-sans-mono
      ubuntu_font_family
      ucs-fonts
      vistafonts
      zilla-slab

      nerd-fonts.jetbrains-mono

      # Conflict
      # proggyfonts
      # broke 11/23
      #dina-font
    ]
    ++ [
      fishPlugins.z # common directories
      fishPlugins.bass # source bash stuff
      # fishPlugins.fishtape_3
      # fishPlugins.fzf-fish # ctrl j file search
      fishPlugins.autopair # add/remove paired delimeters automatically; e.g. (), [], {}, "", ''
      fishPlugins.clownfish # "mock" command
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      fishPlugins.async-prompt # broken on macos
    ];

    sessionVariables = {
      EDITOR = "code --wait --new-window";
    };

    file = {
      ".tmux.conf".source = ../../dot/.tmux.conf;
      ".local/bin" = {
        recursive = true;
        source = ../../dot/local/bin;
      };
      "dev".source = ../shells;
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
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      inline_height = "0";
      style = "auto";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source

      set -gx FZF_DEFAULT_COMMAND "fdfind . $HOME"
      set -gx FZF_LEGACY_KEYBINDS 0
      set -gx FZF_COMPLETE 1

      set -U fish_greeting
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

      replace-all.body = ''
        set -f find $argv[1]
        set -f rep $argv[2]
        set -f filter $argv[3]
        if test $filter
            echo "Replacing /$find/ with /$rep/ with extra $filter"
            rg --files-with-matches $filter | rg $find --files-with-matches | xargs sed -i "s/$find/$rep/g"
        else
            echo "Replacing /$find/ with /$rep/"
            rg $find --files-with-matches | xargs sed -i "s/$find/$rep/g"
        end
      '';

      sk.body = ''
        set -x SIGNING_KEY (gpg --list-secret-keys --keyid-format long | grep $EMAIL -B 3 | grep "(work|github|disco|1E7452EAEE)" -B 3 | grep sec | string split "/" | tail -n 1 | string match -r '[0-9A-F]+')
        echo "Set Signing key to $SIGNING_KEY"
        git config --global user.signingkey $SIGNING_KEY > /dev/null
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

    # borked
    #plugins = with fishPlugins; [
    #  z # common directories
    #  bass # source bash stuff
    #  fzf-fish # ctrl j file search
    #  async-prompt # yep
    #  autopair # add/remove paired delimeters automatically; e.g. (), [], {}, "", ''
    #  clownfish # "mock" command
    #];
  };

  programs.tmux = {
    enable = true;
    #    extraConfig = with config.scheme.withHashtag; ''
    #      # COLOUR (base16)
    #
    #      # base00: " #282828 "
    #      # base01: " #3c3836 "
    #      # base02: " #504945 "
    #      # base03: " #665c54 "
    #      # base04: " #928374 "
    #      # base05: " #ebdbb2 "
    #      # base06: " #fbf1c7 "
    #      # base07: " #f9f5d7 "
    #      # base08: " #cc241d "
    #      # base09: " #d65d0e "
    #      # base0A: " #d79921 "
    #      # base0B: " #98971a "
    #      # base0C: " #689d6a "
    #      # base0D: " #458588 "
    #      # base0E: " #b16286 "
    #      # base0F: " #9d0006 "
    #      # base10: " #2a2520 "
    #      # base11: " #1d1d1d "
    #      # base12: " #fb4934 "
    #      # base13: " #fabd2f "
    #      # base14: " #b8bb26 "
    #      # base15: " #8ec07c "
    #      # base16: " #83a598 "
    #      # base17: " #d3869b "
    #
    #      # default statusbar colors
    #      set-option -g status-style "fg=#${base04},bg=#${base00}"
    #
    #      # default window title colors
    #      set-window-option -g window-status-style "fg=${base05},bg=${base02}"
    #
    #      # active window title colors
    #      set-window-option -g window-status-current-style "fg= #${base14},bg=${base01}"
    #
    #      # pane border
    ##      set-option -g pane-border-style "fg= #3c3836"
    # #     set-option -g pane-active-border-style "fg= #504945"
    #
    #      # message text
    #  #    set-option -g message-style "fg= #d5c4a1,bg= #3c3836"
    #
    #      # pane number display
    # #     set-option -g display-panes-active-colour "#b8bb26"
    #  #    set-option -g display-panes-colour "#fabd2f"
    #
    #      # clock
    #  #    set-window-option -g clock-mode-colour "#b8bb26"
    #
    #      # copy mode highligh
    #   #   set-window-option -g mode-style "fg= #bdae93,bg= #504945"
    #
    #      # bell
    #   #   set-window-option -g window-status-bell-style "fg= #3c3836,bg= #fb4934"
    #    '';
    plugins = with tmuxPlugins; [
      sensible
      gruvbox
      #catppuccin # colors
      battery # seeing battery in remote session
      continuum # tmux session restore
      # vim-tmux-navigator
    ];
  };
}
