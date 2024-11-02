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
    } @inputs:
    let
      home = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ewan = import ./nixos/home.nix;
        extraSpecialArgs = { inherit spicetify-nix; };
      };
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          ./nixos/machine/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = home;
          }
        ];
        specialArgs = { inherit nixvirt; };
      };
      nixosConfigurations.elbozo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          ./nixos/elbozo/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = home;
          }
        ];
      };
      darwinConfigurations.D430N0H49X = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          ./nix-macos/system.nix
        ];
      };
    };
}


