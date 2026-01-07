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
    { self, flake-utils, nixpkgs, ... }@inputs:
    import ./systems.nix inputs
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs { inherit system; });
        pkglist = with pkgs; [
          fish
          (writeShellScriptBin "update" ''
            nix flake update secrets
            alias sudo='printf "\n%s\n" "waiting for authentication..." > /dev/stdout; sudo'
            nixos-rebuild switch \
              --flake .#$hostname \
              --max-jobs $REBUILD_JOBS \
              --cores $REBUILD_CORES \
              --sudo \
              --show-trace
          '')
        ];
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = pkglist;
          buildInputs = pkglist;
          packages = pkglist;
        };
      }
    );
}
