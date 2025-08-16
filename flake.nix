{
  inputs = {
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # i hate absolute paths
    secrets.url = "path:/mnt/c/msys64/home/ewan/shit/secrets";

    # Secrets
    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Hardware detection
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , flake-utils
    , nix-minecraft
    , disko
    , nixos-facter-modules
    , secrets
    , ...
    }:
    {
      nixosConfigurations.ewangreen = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          # inherit (secrets) secrets inputs nixpkgs;
          inherit inputs nixpkgs;
          secrets = builtins.trace "SECRETS VALUE: ${builtins.toJSON secrets.secrets}"
                    secrets.secrets;
        };
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./postgres.nix
          nix-minecraft.nixosModules.minecraft-servers
          {
            nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
          }
          nixos-facter-modules.nixosModules.facter
          {
            config.facter.reportPath =
              if builtins.pathExists ./facter.json then
                ./facter.json
              else
                throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
          }
        ];
      };
    };
}
