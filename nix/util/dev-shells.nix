{ pkgs, ... }:
let
  prefix = "dev-shell-";

  mkDevShellFlakePkg = name: envrc: flake: pkgs.stdenvNoCC.mkDerivation {
    pname = "${prefix}${name}";
    version = "0.1.0";
    dontUnpack = true;
    # expose as env vars for bash
    envrcText = envrc;
    flakeText = flake;
    installPhase = ''
      install -Dm666 <(printf '%s' "$flakeText") $out/flake.nix
      install -Dm666 <(printf '%s' "$envrcText") $out/.envrc
    '';
  };

  mkDevShells = builtins.mapAttrs (name: value:
    let
      v = if builtins.isList value then value else [ "use flake" value ];
    in
    mkDevShellFlakePkg name (builtins.elemAt v 0) (builtins.elemAt v 1));

  dev-shell = name: "${dev-shells.${name}}";

  dev-shells = mkDevShells {
    "rust-sys" = ''
      {
        inputs = {
          nixpkgs.url = "github:nixos/nixpkgs";
          flake-utils.url = "github:numtide/flake-utils";
          rust-overlay.url = "github:oxalica/rust-overlay";
        };
        outputs =
          {
            nixpkgs,
            flake-utils,
            rust-overlay,
            ...
          }:
          flake-utils.lib.eachDefaultSystem (
            system:
            let
              overlays = [ (import rust-overlay) ];
              pkgs = import nixpkgs { inherit system overlays; };
              stdenv = pkgs.stdenvAdapters.useWildLinker pkgs.gccStdenv;
              rust = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
                extensions = ["rust-src"];
              });

              buildInputs = [ rust ] ++ (with pkgs; [
                rustPlatform.bindgenHook
                rustPlatform.rustcSrc
                pkg-config
              ]);
              nativeBuildInputs = [
                pkgs.rustc
              ];
            in
            {
              allowUnfree = true;
              devShell = pkgs.mkShell rec {
                inherit stdenv buildInputs nativeBuildInputs;
                packages = buildInputs ++ nativeBuildInputs;

                LLVM_CONFIG_PATH = "''${pkgs.llvm}/bin/llvm-config";
                LD_LIBRARY_PATH = "''${nixpkgs.lib.makeLibraryPath buildInputs}";
                RUSTFLAGS="-Ctarget-cpu=haswell";
                RUST_SRC_PATH = "''${pkgs.rustPlatform.rustLibSrc}";
                RUST_BACKTRACE = "full";
              };
            }
          );
      }
    '';
    "cpp-cmake" = "";
    "rust-traditional" = "";
    "cpp-cmake-traditional" = "";
    "python" = "";
    "nixpkgs" = "";
  };

  new-dev-shell = pkgs.writeShellScriptBin "new-dev-shell" ''
    function prompt {
        local output="$(echo -e "$2" | tr ';' '\n' | fzf --ansi \
            --header "$1" \
            --header-first \
            --ghost "$3" \
            --print-query \
            --bind 'tab:transform-query(echo {1})' \
            --delimiter=$'\t'\
            --preview 'awk -F "\t" "{ if (NR==FNR) print \$2 }" <<< {}' \
            --tabstop 12 \
            --preview-window=hidden \
        )"
        export code=$?

        local query="$(head -n1 <<< "$output")"
        local selection="$(tail -n1 <<< "$output" | cut -f1)"

        if [ ! -z "$query" ]; then
            output="$query"
        else
            output="$selection"
        fi

        [ -n "$output" ] && printf "%s" "$output" || return $code
    }

    function error {
        printf "\033[31m%s\033[0m: %s\n" "error" "''${@:2}"
        exit $1
    }

    prompt "Create a development environment from template '$1'?\nWorking directory: $PWD" "Yes;No" "Yes"

    case "$1" in
      ${pkgs.lib.concatMapAttrsStringSep "\n" (name: value: ''
        "${name}") cp -rT "${value}" .;;
      '') dev-shells}
      *) error 1 "No existing dev shell matching '$1'";;
    esac
    clear
    direnv allow
  '';
in
{
  inherit dev-shells dev-shell new-dev-shell;
}
