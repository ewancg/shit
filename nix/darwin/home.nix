{nixpkgs, ...}: { home-manager = {

  backupFileExtension = "backup.darwin";
  useGlobalPkgs = true;
  useUserPackages = true;

  users.ewan = nixpkgs.lib.mkMerge [
    # These must be matched inside of where they're used    
    ../home/base.nix

    { home = {
        homeDirectory = "/Users/egreen";
        username = "egreen";
    };}
  ];
};}
