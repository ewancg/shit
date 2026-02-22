{
  inputs = {
    secrets.url = "path:/home/ewan/shit/secrets";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    hyprland.url = "github:hyprwm/Hyprland";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, flake-utils, nixpkgs, ... }@inputs:
    import ./systems.nix inputs
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs { inherit system; });
        upfrontAuth = true;
      in
      {
        devShell = with pkgs; mkShell {
          nativeBuildInputs = [
            (lib.optionals (!upfrontAuth) (pkgs.writeShellScriptBin "sudo" ''
              printf "\33[2K%s\n" "awaiting authentication..."
              /run/wrappers/bin/sudo "$@"
              printf "\33[2K\r"
            ''))
            (writeShellScriptBin "rebuild" ''
              nixos-rebuild switch --flake .#$(hostname) \
                --max-jobs 24 \
                --cores 8 \
                --no-reexec \
                --show-trace \
                $@
            '')
            (writeShellScriptBin "update" ''
              nix flake update secrets
              ${if upfrontAuth then ''
                printf "\33[2K%s\n" "awaiting upfront authentication..."
                user="$(whoami)"
                HOME= sudo -E rebuild
                printf "\33[2K\r"
              '' else ''
                rebuild --sudo
              ''}
            '')
          ];
          buildInputs = [ fish ];
        };
      }
    );
}
