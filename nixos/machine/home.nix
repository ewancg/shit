{ config, pkgs, ... }:

{
  home.username = "ewan";
  home.homeDirectory = "/home/ewan";
  home.stateVersion = "24.05";

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ firefox pkg-config ]);
  };

  home.packages = with pkgs; [

  ];

  xdg.configFile = {
    "alacritty".source = ../../alacritty;
    #"alacritty/theme".source = config.lib.file.mkOutOfStoreSymlink ../../dracula.toml;
    
    #"fish/config.fish".source = config.lib.file.mkOutOfStoreSymlink ../../fish/config.fish;

 #   "Yubico/u2f_keys".source = config.lib.file.mkOutOfStoreSymlink /etc/u2f_mappings;
  };


  #home-manager.users.gdm = { lib, ... }: {
  #  dconf.settings = {
  #    "org/gnome/desktop/interface" = {
  #      scaling-factor = lib.hm.gvariant.mkUint32 2;
  #    };
  #};
  #};

  #home-manager.users.ewan = {
    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          gsconnect.extensionUuid
          tiling-assistant.extensionUuid
          window-calls.extensionUuid
          window-calls-extended.extensionUuid
          ddnet-friends-panel.extensionUuid
          user-themes.extensionUuid
          dash-to-panel.extensionUuid
          quick-settings-audio-panel.extensionUuid
         # tray-icons-reloaded.extensionUuid
          appindicator.extensionUuid
        ];
      };
    };
  #};

  home.file = {
    #".tmux.conf".source = ../../.tmux.conf;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "code --wait --new-window";
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ../../fish/config.fish;
    interactiveShellInit = ''
      function __get_program_names
          ps aux | choose 10 | sort | uniq
      end

      complete -r -c mullvad-split-tunnel -a "(__get_program_names)"
    '';
    functions = {
      nixbuildconf.body = ''sudo nixos-rebuild --flake ~/shit/nixos#machine switch'';
      nixpkg.body = ''NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixos."$1"'';
      hostname.body = "/usr/bin/env cat /etc/hostname";
      kc.body = ''
        set -f new_env (kubectl config get-contexts -o name | fzf)
        if test "A$new_env" = "A"
            exit 1
        end
        kubectl config use-context $new_env
      '';
      mullvad-split-tunnel.body = ''
        set appname "$argv[1]";
        set procs (ps aux | grep $appname | grep -v "0:00 rg" | choose 0)
        set num_procs (echo $procs | wc -l)

        # Echo to stderr so that other scripts can use this command
        echo 1>&2 "Ignoring $appname ($num_procs matches)";
        for pid in $procs;
            echo -n "Split-tunneling $pid ... ";
            mullvad split-tunnel add $pid;
        end
        echo 1>&2 "Done"
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
    extraConfig = builtins.readFile ../../.tmux.conf;
    #plugins = with pkgs.tmuxPlugins; [
      #sensible
      #tmux-colors-solarized
      # tokyo-night-tmux
      #catppuccin
      # tmux-battery
      #vim-tmux-navigator
      # set -g @plugin 'tmux-plugins/tmux-sensible'
      # set -g @plugin 'seebi/tmux-colors-solarized'
      # #set -g @plugin 'janoamaral/tokyo-night-tmux'
      # set -g @plugin 'catppuccin/tmux'
      # set -g @plugin 'tmux-plugins/tmux-battery'
      # set -g @plugin 'christoomey/vim-tmux-navigator'
    #];
  };


}
