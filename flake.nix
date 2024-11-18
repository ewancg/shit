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
      home-nixos = {
        backupFileExtension = "backup";
        useGlobalPkgs = true;
        useUserPackages = true;

        users.ewan = nixpkgs.lib.mkMerge [
          # These must be matched inside of where they're used
          ./nix/home/desktop.nix
          ./nix/home/apps.nix
          ./nix/home/base.nix

          { home = {
              homeDirectory = "/home/ewan";
              username = "ewan";
          };}
        ];
      };
      home-macos = {
        backupFileExtension = "backup.darwin";
        useGlobalPkgs = true;
        useUserPackages = true;

        users.egreen = nixpkgs.lib.mkMerge [
          # These must be matched inside of where they're used
          ./nix/home/base.nix

          { home = {
              homeDirectory = "/Users/egreen";
              username = "egreen";
          };}
        ];
      };
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
            inherit nixvirt home-manager nixpkgs;
        };
        modules = [
            ./nix/os/configuration.nix
            ./nix/os/machine/system.nix
            home-manager.nixosModules.home-manager ./nix/os/home.nix
                #{
                #nixpkgs.lib.mkMerge [
                    #{ home-manager.extraSpecialArgs = { inherit nixpkgs; }; }
                    #{
                    #    nixpkgs.lib.callPackageWith ./nix/os/home.nix { nixpkgs = nixpkgs; };
                    #}
                #]
                #}
        ];
      };
      nixosConfigurations.elbozo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        extraSpecialArgs = {
          inherit nixpkgs;
        };
        modules = [
         # ./nix/os/configuration.nix
         # ./nix/os/elbozo/system.nix
         # home-manager.nixosModules.home-manager {
         #   home-manager = ./nix/os/home.nix;
         # }
        ];
      };
      darwinConfigurations.D430N0H49X = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ 
            ./nix/darwin/system.nix

            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager {
            home-manager = ./nix/darwin/home.nix;
            }
          ];  
      };
	buildInputs = [ 
		nixpkgs.git
	];
    };
}


