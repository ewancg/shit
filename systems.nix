{
  self,
  ...
}@inputs:
let
  inherit (inputs)
    disko
    firefox
    hyprland
    nixvirt
    ;
  secrets = (inputs.secrets.secrets);
  mkUtil = import ./nix/util.nix;
in
with (mkUtil {inherit secrets inputs;}).systems; {
  nixosConfigurations = mkConfigs ./. mkUtil {
    machine = mkNixosModuleWithUser "x86_64-linux" { inherit nixvirt firefox hyprland; } [ disko.nixosModules.disko ];
    elbozo = mkNixosModuleWithUser "x86_64-linux" { inherit nixvirt firefox; } [ ];
  };
}
