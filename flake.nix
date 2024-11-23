{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # machine
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixoses
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # worktop
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    #    vfkit-tap =
    #      {
    #        url = "github:cfergeau/homebrew-crc";
    #        flake = false;
    #      };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    gimme-aws-creds.url = "github:Nike-Inc/gimme-aws-creds";
    awsctx.url = "github:john2143/dotfiles/7bd638d74e9c5809396bbdbd7b6c497de1a50ec6?dir=awsctx";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , spicetify-nix
    , hyprland
    , nixvirt
    , nix-darwin
    , nix-homebrew
    , homebrew-core
    , homebrew-cask
      #, vfkit-tap
    , flake-utils
    , gimme-aws-creds
    , awsctx
    , ...
    } @inputs: {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixvirt home-manager nixpkgs spicetify-nix;
        };
        modules = [
          ./nix/os/configuration.nix
          ./nix/os/machine/system.nix
          home-manager.nixosModules.home-manager
          ./nix/os/home.nix
        ];
      };
      nixosConfigurations.elbozo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs nixpkgs; };
        modules = [
          ./nix/os/configuration.nix
          ./nix/os/elbozo/system.nix
          home-manager.nixosModules.home-manager
          ./nix/os/home.nix
        ];
      };
      darwinConfigurations.D430N0H49X = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs nixpkgs; };
        modules = [
          ./nix/darwin/system.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          ./nix/darwin/home.nix
        ];
      };
    };
}


