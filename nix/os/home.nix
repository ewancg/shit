{nixpkgs, ...}: { home-manager = {

  backupFileExtension = "backup";
  useGlobalPkgs = true;
  useUserPackages = true;

  users.ewan = nixpkgs.lib.mkMerge [
    # These must be matched inside of where they're used
    ../home/desktop.nix
    ../home/apps.nix
    ../home/base.nix

    { home = {
        homeDirectory = "/home/ewan";
        username = "ewan";
    };}
  ];
};}
