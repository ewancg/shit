{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    # spicetify-nix = {
    #   url = "github:Gerg-L/spicetify-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, hyprland, nixvirt, ... }@inputs:
    let
      system = "x86_64-linux";
      home = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ewan = import ./home.nix;
        extraSpecialArgs = { inherit spicetify-nix; };
      };
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "${system}";
        modules = [
          ./configuration.nix
          ./machine/system.nix
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
          ./configuration.nix
          ./elbozo/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = home;
          }
        ];
      };
    };
}


