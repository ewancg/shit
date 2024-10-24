{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, hyprland, nixvirt, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, ... }@inputs:
    let
      system = "x86_64-linux";
      home = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ewan = import ./nixos/home.nix;
        extraSpecialArgs = { inherit spicetify-nix; };
      };
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "${system}";
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
          modules = [ 
            nix-homebrew.darwinModules.nix-homebrew
            ./nix-macos/system.nix 
            ];
      };
    };
}


