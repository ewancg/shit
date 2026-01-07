{ secrets, inputs, ... }:
let
  inherit (inputs)
    home-manager
    nixpkgs
    stylix
    ;

  mkBaseHomeModule = args: root: hostname: { config, pkgs, lib, util, ... }: {
    home-manager.extraSpecialArgs = args // { inherit secrets root hostname util; };
    home-manager.useUserPackages = true;
  };

  mkBaseNixosModule =
    system: args: modules: root: mkUtil: hostname:
    nixpkgs.lib.nixosSystem {
      specialArgs = args // {
        inherit mkUtil secrets root hostname;
      };
      modules = modules ++ [
        (root + /nix/os/configuration.nix)
        (root + /nix/os/${hostname}/system.nix)
        ({ config, pkgs, lib, ... }: {
          _module.args.util = mkUtil {
            inherit secrets root hostname config pkgs;
          };
        })
      ];
    };
in
{
  inherit mkBaseNixosModule;

  mkNixosModuleWithUser =
    system: args: modules: root: mkUtil: hostname:
    let
      a = args // {
        inherit home-manager stylix;
      };
      m = modules ++ [
        home-manager.nixosModules.home-manager
        (mkBaseHomeModule a root hostname)
        (root + /nix/os/home.nix)
      ];
    in
    (mkBaseNixosModule system a m root mkUtil hostname);

  # mkConfigs is intended to be called from outside a nix module.
  # mkUtil should create a util suitable for the config modules.
  mkConfigs =
    root: mkUtil: configs:
    builtins.mapAttrs (hostname: f: f root mkUtil hostname) configs;
}
