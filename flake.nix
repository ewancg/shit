{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";

    ## machine only
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";

    ## desktop nixoses
    hyprland.url = "github:hyprwm/Hyprland";

    ## work laptop top only
    awsctx.url = "github:john2143/dotfiles/7bd638d74e9c5809396bbdbd7b6c497de1a50ec6?dir=awsctx";
    gimme-aws-creds.url = "github:Nike-Inc/gimme-aws-creds";
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    netkit.url = "github:icebox-nix/netkit.nix";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hyprland
    , nixvirt
    , nix-darwin
    , nix-homebrew
    , homebrew-core
    , homebrew-cask
    , mac-app-util
      #, vfkit-tap
    , netkit
    , flake-utils
    , gimme-aws-creds
    , awsctx
    , ...
    } @inputs: {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixvirt inputs home-manager nixpkgs;
        };
        modules = [
          ./nix/os/configuration.nix
          ./nix/os/machine/system.nix
          home-manager.nixosModules.home-manager
#          netkit.nixosModule
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
#          netkit.nixosModule
          ./nix/os/home.nix
        ];
      };
      darwinConfigurations.D430N0H49X = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs nixpkgs mac-app-util; };
        modules = [
          ./nix/darwin/system.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          mac-app-util.darwinModules.default
          ./nix/darwin/home.nix
        ];
      };
    };
}


