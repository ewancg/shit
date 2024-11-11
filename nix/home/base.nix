# home/base.nix; home config for all users (terminal, cli utilities, dev env...)

{ pkgs, ... }:
with pkgs; 
{
  home = {
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
      grim

      killall
      p7zip
      playerctl
      traceroute
      unzip

      # virt

      # system
      glibcLocales

      # Nix
      direnv
      nil
      nix-index
      nix-ld
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
    "alacritty".source = ../../dot/alacritty;
  };

    programs.fish = {
    enable = true;
    interactiveShellInit = ''
      bass source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      direnv hook fish | source

      set -gx FZF_DEFAULT_COMMAND "fdfind . $HOME"
      set -gx FZF_LEGACY_KEYBINDS 0
      set -gx FZF_COMPLETE 1
      source "$HOME/.config/fish/fzf.fish"
    '';
    functions = {
      nixbuildconf.body = ''sudo nixos-rebuild --flake ~/shit/nixos#$hostname switch'';
      start.body = ''xdg-open $@'';
      nixpkg.body = ''NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixos."$1"'';
      hostname.body = "/usr/bin/env cat /etc/hostname";
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
    plugins = [
    ];
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      # tmux-colors-solarized
      # tokyo-night-tmux
      catppuccin
      # tmux-battery
      # vim-tmux-navigator
    ];
  };
}