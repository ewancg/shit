{
  lib,
  stylix,
  util,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = { inherit util; };
    backupFileExtension = "backup";
    useGlobalPkgs = false;
    useUserPackages = true;

    users.ewan = lib.mkMerge [
      # These must be matched inside of where they're used
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
    #users.egreen = nixpkgs.lib.mkMerge [
    #  # These must be matched inside of where they're used
    #  ../home/desktop.nix
    #  ../home/office.nix
    #  ../home/base.nix
    #  {
    #    home = {
    #      homeDirectory = nixpkgs.lib.mkForce "/home/egreen";
    #      username = "egreen";
    #    };
    #  }
    #];
  };
}
