{ lib
, stylix
, ...
}: {
  home-manager = {
    sharedModules = [
      ../home/base.nix
    ];

    users.ewan = lib.mkMerge [
      ../home/desktop.nix
      ../home/apps.nix
      ../home/office.nix
      stylix.homeModules.stylix
      {
        home = {
          homeDirectory = lib.mkForce "/home/ewan";
          username = "ewan";
        };
      }
    ];
  };
}
