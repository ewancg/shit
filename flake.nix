{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets.url = "path:/home/ewan/shit/secrets";
  };

  outputs =
    {
      secrets,
      self,

      disko,
      firefox,
      flake-utils,
      home-manager,
      hyprland,
      nixpkgs,
      nixvirt,
      stylix,
      ...
    }@inputs:
    let
      util = (pkgs: (import ./nix/util.nix) { inherit pkgs secrets; });
      pkgs = (system: nixpkgs.legacyPackages.${system});
      secrets = (inputs.secrets.secrets);
    in
    {
      nixosConfigurations.machine =
        let
          system = "x86_64-linux";
        in
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit
              system
              secrets

              nixvirt
              firefox

              home-manager
              hyprland
              stylix
              ;
            util = (util (pkgs system));
          };

          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./nix/os/configuration.nix
            ./nix/os/machine/system.nix
            ./nix/os/home.nix
          ];
        };
      nixosConfigurations.elbozo =
        let
          system = "x86_64-linux";
        in
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit
              secrets

              firefox

              home-manager
              stylix
              ;
            util = (util (pkgs system));
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./nix/os/configuration.nix
            ./nix/os/elbozo/system.nix
            ./nix/os/home.nix
          ];
        };
      # darwinConfigurations.D430N0H49X =
      #   let
      #     system = "aarch64-darwin";
      #   in
      #   nix-darwin.lib.darwinSystem {
      #     system = system;
      #     specialArgs = {
      #       inherit (secrets)
      #         secrets
      #         mac-app-util
      #       ;
      #       pkgs = (pkgs system);
      #       util = (util (pkgs system));
      #     };
      #     modules = [
      #       nix-homebrew.darwinModules.nix-homebrew
      #       home-manager.darwinModules.home-manager
      #       mac-app-util.darwinModules.default
      #       ./nix/darwin/system.nix
      #       ./nix/darwin/home.nix
      #     ];
      #   };
    };
}
