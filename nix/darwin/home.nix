{ nixpkgs, ... }: {
  home-manager = {

    backupFileExtension = "backup.darwin";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.egreen = nixpkgs.lib.mkMerge [
      # These must be matched inside of where they're used    
      ../home/base.nix
      {
        home = {
          homeDirectory = nixpkgs.lib.mkForce "/Users/egreen";
          username = "egreen";
        };
      }
    ];
  };
}
