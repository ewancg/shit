{ pkgs, inputs, config, lib, ... }:
let
  rust = with pkgs; [
    cargo
    rustc
    rustfmt
    pre-commit
    rustPackages.clippy

    # rust is needed system-wide for vscode rust-analyzer extension and such... not covered by direnv extension
  ];
in
{
  imports = [
    ./nix-darwin-activation.nix
    ./touch-id.nix

    # ../misc/ollama.nix

    # Home Manager accommmodations
    ../home/base-accommodations.nix

    # nvim config
    ../home/neovim.nix
  ];
  system.stateVersion = 5;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    # package = pkgs.nix;
    # idk
    # package = pkgs.nixFlakes;

    # how did i end up with 3
    #extraOptions = ''
    #  experimental-features = nix-command flakes
    #'';
    #settings.experimental-features = [ "nix-command" "flakes" ];
    settings.experimental-features = "nix-command flakes";

    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };
  };
  environment.systemPackages = with pkgs; [
    ## gui
    vscode
    jetbrains.rust-rover
    zed-editor
    bruno

    # Clouds
    # lens
  
    # depends on vfkit which i cant get
    #podman

    ## the rest
    git
    github-cli
    # awscli
    awscli2

    # Docker runtime 
    colima
    # Docker compose plugin
    docker-compose
    # Docker build plugin (default is legacy)
    docker-buildx

    # Shell
    #tmux
    #fish
    #starship # prompt

    # dataing
    dasel
    jq

    fzf
    tree
    nixpkgs-fmt
    nil
    direnv

    #nodePackages.nodejs
    nodejs_22
    # nodePackages.npm

    k9s

    # python311Packages.python-lsp-server


    # Both the flake and nixpkgs versions of this are broken as of 10/24/24; using brew
    # gimme-aws-creds
    # inputs.gimme-aws-creds.defaultPackage."aarch64-darwin"
    inputs.awsctx.defaultPackage.${pkgs.system}
  ]
  ;

  environment.shells = [
    pkgs.fish
    pkgs.bash
    pkgs.bashInteractive
    pkgs.zsh
  ];


  # Required for home-manager.users.* to work
  users.users.egreen = {
    description = "Ewan Green";
    shell = pkgs.bashInteractive;
    home = "/Users/egreen";
    name = "egreen";
  };

  # Enable zsh in order to add /run/current-system/sw/bin to $PATH, because the Nix installer on macOS only hooks into bashrc & zshrc
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # idk
  environment.loginShellInit = ''
    export SHELL="$(dscl . -read /Users/$(id -un) UserShell | awk '{print $2}')"
  '';
  #programs.tmux = {
  #  shell = "${lib.getExe pkgs.fish}";
  #  terminal = "${lib.getExe pkgs.alacritty}";

  #  enable = true;
  #  enableFzf = true;
  #  enableSensible = true;

  #  extraConfig = ''
  #  set -gu default-command
  #  set -g default-shell "$SHELL"
  #'';
  #};
  #programs.zsh = {
  #  interactiveShellInit = ''
  #    export SHELL="$(dscl . -read /Users/$(id -un) UserShell | awk '{print $2}')"
  #    set PPID="$(ps -o ppid -p $$ | sed -n '2 p')"
  #    if [[ "basename `$(ps -o comm -p $PPID | sed -n '2 p')`" != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
  #    then
  #      export SHELL="$(dscl . -read /Users/$(id -un) UserShell | awk '{print $2}')"
  #      [[ -o login ]] && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  #      exec $SHELL $LOGIN_OPTION
  #      # shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  #      # exec ${lib.getExe pkgs.fish} $LOGIN_OPTION
  #    fi
  #  '';
  #};
  programs.fish = {
    shellInit = ''
      for p in /run/current-system/sw/bin
        if not contains $p $fish_user_paths
          set -g fish_user_paths $p $fish_user_paths
        end
      end
    '';
  };

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "egreen";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      #  # "cfergeau/homebrew-crc" =  inputs.vfkit-tap;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = true;
  };
}
