{ nixpkgs, spicetify-nix, ... }: {

  home-manager = {

    backupFileExtension = "backup";
    useGlobalPkgs = false;
    useUserPackages = true;

    users.ewan = nixpkgs.lib.mkMerge [
      # These must be matched inside of where they're used    
      ../home/desktop.nix
      ../home/apps.nix
      ../home/office.nix
      ../home/base.nix
      {
        home = {
          homeDirectory = nixpkgs.lib.mkForce "/home/ewan";
          username = "ewan";
        };
      }
    ];
    users.egreen = nixpkgs.lib.mkMerge [
      # These must be matched inside of where they're used    
      ../home/desktop.nix
      ../home/office.nix
      ../home/base.nix
      {
        home = {
          homeDirectory = nixpkgs.lib.mkForce "/home/egreen";
          username = "egreen";
        };
      }
    ];
  };
}
