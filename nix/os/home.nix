{
  lib,
  stylix,
  util,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = { inherit util; };
    # backupFileExtension = "backup";
    useGlobalPkgs = false;
    useUserPackages = true;

    users.ewan = lib.mkMerge [
      stylix.homeModules.stylix
      ../home/desktop.nix
      ../home/apps.nix
      ../home/office.nix
      ../home/base.nix
      {
        home = {
          homeDirectory = lib.mkForce "/home/ewan";
          username = "ewan";
        };
      }
    ];
  };
}
