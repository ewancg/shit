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

    # Home Manager accommmodations
    ../home/base-accommodations.nix
  ];
  system.stateVersion = 5;

  security.pam.enableSudoTouchIdAuth = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  services.nix-daemon.enable = true;

  # Required for home-manager.users.* to work
  users.users.egreen = {
    description = "Ewan Green";
    home = "/Users/egreen";
    name = "egreen";
  };

  home-manager = {
    users.egreen = {
      home = {
        homeDirectory = "/Users/egreen";
        username = "egreen";
      };
    };
  };
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

    # Clouds
    lens

    # depends on vfkit which i cant get
    #podman

    ## the rest
    git
    github-cli
    awscli

    # Shell
    #tmux
    #fish
    #starship # prompt

    # dataing
    dasel
    jq

    fzf
    tree
    alacritty
    nixpkgs-fmt
    nil
    direnv

    #nodePackages.nodejs
    nodejs_22
    # nodePackages.npm

    python311Packages.python-lsp-server

    # Both the flake and nixpkgs versions of this are broken as of 10/24/24; using brew
    # gimme-aws-creds
    # inputs.gimme-aws-creds.defaultPackage."aarch64-darwin"
    inputs.awsctx.defaultPackage.${pkgs.system}
  ] ++ rust;

  environment.shells = [
    pkgs.fish
    pkgs.bash
    pkgs.zsh
  ];

  # Enable zsh in order to add /run/current-system/sw/bin to $PATH, because the Nix installer on macOS only hooks into bashrc & zshrc
  programs.zsh.enable = true;
  programs.fish.enable = true;

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
