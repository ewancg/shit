{
  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    hyprland.url = "github:hyprwm/Hyprland";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      disko,
      flake-utils,
      home-manager,
      hyprland,
      nixpkgs,
      nixvirt,
      stylix,
      ...
    }@inputs:
    let
      util = import ./nix/util.nix;
    in
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit
            nixvirt
            inputs
            home-manager
            nixpkgs
            util
            ;
        };
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./nix/os/configuration.nix
          ./nix/os/machine/system.nix
          ./nix/os/home.nix
        ];
      };
      nixosConfigurations.elbozo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs nixpkgs;
          util = util;
        };
        modules = [
          home-manager.nixosModules.home-manager
          ./nix/os/configuration.nix
          ./nix/os/elbozo/system.nix
          ./nix/os/home.nix
        ];
      };
      # darwinConfigurations.D430N0H49X = nix-darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   specialArgs = { inherit inputs nixpkgs mac-app-util; };
      #   modules = [
      #     nix-homebrew.darwinModules.nix-homebrew
      #     home-manager.darwinModules.home-manager
      #     mac-app-util.darwinModules.default
      #     ./nix/darwin/system.nix
      #     ./nix/darwin/home.nix
      #   ];
      # };
    };
}
