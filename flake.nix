{
  inputs = {
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , flake-utils
    , nix-minecraft
    , ...
    }:
    {
      nixosConfigurations.minecraft = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs nixpkgs;
        };
        modules = [
          ./configuration.nix
          #			./minecraft.nix
          nix-minecraft.nixosModules.minecraft-servers
          {
            nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
          }
        ];
      };
    };
}
