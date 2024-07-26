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
};

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "${system}";
        # extraSpecialArgs = {inherit inputs;};
        modules = [
          inputs.home-manager.nixosModules.default
          ./machine/configuration.nix
        ];
      };
      #      nixosConfigurations.slave = nixpkgs.lib.nixosSystem {
      #        system = "${system}";
      #        # extraSpecialArgs = {inherit inputs;};
      #        modules = [
      #          inputs.home-manager.nixosModules.default
      #          ./slave/configuration.nix
      #        ];
      #      };

    };
}


