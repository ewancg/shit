{ nixpkgs, mac-app-util, ... }: {
  home-manager = {

    backupFileExtension = "backup.darwin";
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      mac-app-util.homeManagerModules.default
    ];

    users.egreen = nixpkgs.lib.mkMerge [
      # These must be matched inside of where they're used    
      ../home/base.nix
      ./aerospace.nix
      {
        home = {
          homeDirectory = nixpkgs.lib.mkForce "/Users/egreen";
          username = "egreen";
        };
      }
    ];
  };
}
