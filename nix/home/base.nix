# home/base.nix; home config for all users (terminal, cli utilities, dev env...)

{ pkgs, ... }:
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


      # Not Windows fonts
      #cantarell-fonts
      corefonts
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
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
    ] ++ [
      fishPlugins.z # common directories
      fishPlugins.bass # source bash stuff
      # fishPlugins.fishtape_3      
      # fishPlugins.fzf-fish # ctrl j file search
      fishPlugins.async-prompt # yep
      fishPlugins.autopair # add/remove paired delimeters automatically; e.g. (), [], {}, "", ''
      fishPlugins.clownfish # "mock" command
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

  nixpkgs.config = {
    allowUnfree = true;
  };

  xdg.configFile = {
    "alacritty".source = ../../dot/config/alacritty;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source

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
    plugins = with tmuxPlugins; [
      sensible
      catppuccin # colors
      battery # seeing battery in remote session
      continuum # tmux session restore
      # vim-tmux-navigator
    ];
  };
}
