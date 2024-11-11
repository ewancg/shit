{pkgs, ...}:
with pkgs;
let
    vlc-plugin-pipewire = callPackage ../misc/vlc-plugin-pipewire/default.nix { };
in
{
  # VLC pipewire plugin
  environment.variables.VLC_PLUGIN_PATH = "${vlc-plugin-pipewire}/lib";
  environment.systemPackages = [
    vlc-plugin-pipewire
  ];
}