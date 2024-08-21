{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "${system}";
        specialArgs = { inherit inputs;} ;
        modules = [
          inputs.home-manager.nixosModules.default
          ./configuration.nix
          ./machine/system.nix
        ];
      };
      nixosConfigurations.elbozo = nixpkgs.lib.nixosSystem {
        system = "${system}";
        extraSpecialArgs = {inherit inputs;};
        modules = [
          inputs.home-manager.nixosModules.default
          ./configuration.nix
          ./elbozo/system.nix
        ];
      };

      # Me
      homeConfigurations."ewan" = home-manager.lib.homeManagerConfiguration {
        inherit nixpkgs;
        extraSpecialArgs = { inherit spicetify-nix; };
        modules = [
          ./home.nix
        ];
      };
    };
}


