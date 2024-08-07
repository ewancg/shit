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

  outputs = { self, nixpkgs, home-manager, spicetify-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = "x84_64-linux"; };
      # specialArgs = {inherit inputs;};
      #pkgs = nixpkgs.legacyPackages.${system};
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
      homeConfigurations."ewan" = home-manager.lib.homeManagerConfiguration {
        inherit nixpkgs;
        extraSpecialArgs = {inherit spicetify-nix;};
        modules = [
            ./machine/home.nix
            ./machine/spicetify.nix # file where you configure spicetify
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


