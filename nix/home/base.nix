# home/base.nix; home config for all users (terminal, cli utilities, dev env...)

{ config, lib, pkgs, ... }:
with pkgs;
{
  home = {
    stateVersion = "24.05";

    packages = [
      # cli tools
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
      font-awesome
      liberation_ttf
      jetbrains-mono
      mplus-outline-fonts.githubRelease
      noto-fonts
      open-sans
      ubuntu-sans-mono
      ubuntu_font_family
      ucs-fonts
      vistafonts
      zilla-slab

      # Conflict
      # proggyfonts
      # broke 11/23
      #dina-font
    ] ++ (with pkgs.nerd-fonts; [
      # Nerdfonts
      jetbrains-mono
      ubuntu-sans
      ubuntu-mono
    ]) ++ [
      fishPlugins.z # common directories
      fishPlugins.bass # source bash stuff
      # fishPlugins.fishtape
      # fishPlugins.fzf-fish # ctrl j file search
      fishPlugins.autopair # add/remove paired delimeters automatically; e.g. (), [], {}, "", ''
      #fishPlugins.clownfish # "mock" command
      fishPlugins.pure
    ];# ++ lib.optionals pkgs.stdenv.isLinux [
      #fishPlugins.async-prompt # broken on macos
    #];

    sessionVariables = {
      EDITOR = "code --wait --new-window";
    };

    file = {
      ".local/bin" = {
        recursive = true;
        source = ../../dot/local/bin;
      };
      ".config/alacritty/alacritty.toml" = {
      text = ''
      terminal.shell = { program = "${lib.getExe pkgs.tmux}", args = ["-u"] }
      general.live_config_reload = true

      [window]
      dynamic_title = true
      dimensions = { columns = 130, lines = 28 }
      dynamic_padding = true
      decorations = "Buttonless"

      opacity = 0.91
      blur = true

      resize_increments = true

      [scrolling]
      history = 0 # Handled by tmux

      [font]
      size = 11.5

      normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
      bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
      italic = { family = "JetBrainsMono Nerd Font", style = "Regular Italic" }
      bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic" }

      [cursor]
      style = { shape = "Beam", blinking = "Off" }
      blink_interval = 500
      thickness = 0.1

      [mouse]
      bindings = [{ mouse = "Right", mods = "None", action = "Copy" }]

      [[keyboard.bindings]]
      key = "Alt"
      mods = "Control"
      chars = "\uE000"

      ${builtins.readFile  ../../dot/config/alacritty/gruvbox_material.toml }
    '';

    };
      "dev".source = ../shells;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  #xdg.configFile = {
  #  "alacritty" = {
  #    source = ../../dot/config/alacritty;
  #  };
  #};

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    shell = "${lib.getExe pkgs.fish}";

    # sensibleOnTop = true;

    plugins = with tmuxPlugins; [
      sensible
      yank
      cpu
      gruvbox
      #{
      #    plugin = tmuxPlugins.catppuccin;
      #    extraConfig = ''
      #      set-option -sa terminal-features "tmux-256color,:RGB"
      #      set -g @catppuccin_flavour 'mocha'
      #      set -g @catppuccin_status_modules_right "session"
      #      set -g @catppuccin_status_modules_left " "
      #      set -g @catppuccin_status_fill "icon"
      #      set -g @catppuccin_window_number_position "right"
      #      set -g @catppuccin_window_left_separator ""
      #      set -g @catppuccin_window_right_separator " "
      #      set -g @catppuccin_window_middle_separator " █"
      #      set -g @catppuccin_window_number_position "right"
      #      set -g @catppuccin_window_default_fill "none"
      #      set -g @catppuccin_window_default_text "#W"
      #      set -g @catppuccin_window_current_fill "number"
      #      set -g @catppuccin_window_current_text "#W"
      #      set -g @catppuccin_pane_active_border_style "fg=#313244"
      #      set -g status-bg "#11111b" # also duplicated at the bottom of the file
      #      set -g @catppuccin_window_status_style "rounded"
      #      set -g status-right-length 100
      #      set -g status-left-length 100
      #      set -g status-left ""
      #      set -g status-right "#{E:@catppuccin_status_application}"
      #      set -agF status-right "#{E:@catppuccin_status_cpu}"
      #      set -ag status-right "#{E:@catppuccin_status_session}"
      #      set -ag status-right "#{E:@catppuccin_status_uptime}"
      #      set -agF status-right "#{E:@catppuccin_status_battery}"
      #    '';
      #  }
      battery # seeing battery in remote session
      tmux-powerline # statusbar
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-boot-options 'alacritty,fullscreen'
          set -g @continuum-save-interval '5' # save every 5 minutes
        '';
      }
    ];

    extraConfig = ''
      # set -gu default-command
      set -g default-shell "${lib.getExe fish}"
      unbind C-b

      # https://github.com/hasundue/tmux-gruvbox-material/blob/master/dark-soft.conf
      set -g status-justify "left"
      set -g status "on"
      set -g status-left-style "none"
      set -g message-command-style "fg=#ddc7a1,bg=#5b534d"
      set -g status-right-style "none"
      set -g pane-active-border-style "fg=#a89984"
      set -g status-style "none,bg=#3c3836"
      set -g message-style "fg=#ddc7a1,bg=#5b534d"
      set -g pane-border-style "fg=#5b534d"
      set -g status-right-length "100"
      set -g status-left-length "100"
      setw -g window-status-activity-style "none"
      setw -g window-status-separator ""
      setw -g window-status-style "none,fg=#ddc7a1,bg=#3c3836"
      set -g status-left "#[fg=#32302f,bg=#a89984,bold] #S #[fg=#a89984,bg=#3c3836,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#5b534d,bg=#3c3836,nobold,nounderscore,noitalics]#[fg=#ddc7a1,bg=#5b534d] %Y-%m-%d  %H:%M #[fg=#a89984,bg=#5b534d,nobold,nounderscore,noitalics]#[fg=#32302f,bg=#a89984,bold] #h "
      setw -g window-status-format "#[fg=#ddc7a1,bg=#3c3836] #I #[fg=#ddc7a1,bg=#3c3836] #W "
      setw -g window-status-current-format "#[fg=#3c3836,bg=#5b534d,nobold,nounderscore,noitalics]#[fg=#ddc7a1,bg=#5b534d] #I #[fg=#ddc7a1,bg=#5b534d] #W #[fg=#5b534d,bg=#3c3836,nobold,nounderscore,noitalics]"

      set -g prefix 
      set -g escape-time 1
      set -g mouse on
      set -g default-terminal "tmux-256color"

      # set-window-option -g window-active-style bg=terminal
      # set-window-option -g window-style bg="#1c1c1c"

      set -ga terminal-features "*:hyperlinks".

      bind h split-window -h
      bind v split-window -v

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
    '';
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      key_path = "${config.home.homeDirectory}/secrets/ATUIN_KEY";
      ctrl_n_shortcuts = true;
      enter_accept = true;
      filter_mode = "session";
    };
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source

      set -gx pure_enable_nixdevshell true
      set -gx pure_symbol_nixdevshell_prefix '󱄅 '
      
      # too clunky
      set -gx pure_enable_k8s false
      set -gx pure_symbol_k8s_prefix ' '

      set -gx pure_enable_aws_profile true
      
      set -gx pure_symbol_git_stash 'stash'
      set -gx PURE_GIT_DOWN_ARROW '↓'
      set -gx PURE_GIT_UP_ARROW '↑'
      set -gx pure_symbol_reverse_prompt '<><'
      set -gx pure_symbol_prompt '><>'
      set -gx pure_enable_single_line_prompt false
      set --universal pure_check_for_new_release false

      set -gx pure_shorten_prompt_current_directory_length 1

      set -gx FZF_DEFAULT_COMMAND "fdfind . $HOME"
      set -gx FZF_LEGACY_KEYBINDS 0
      set -gx FZF_COMPLETE 1
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

    # borked
    # plugins = with fishPlugins; [
    # autopair # add/remove paired delimeters automatically; e.g. (), [], {}, "", ''
    # bass # source bash stuff
    # tide # prompt
    # fzf-fish # ctrl j file search
    # z # common directories
    # ];
  };
}
