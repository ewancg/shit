{ lib
#, autoconf-archive
#, autoreconfHook
#, boost
, pipewire
# , libtorrent-rasterbar
, libvlc
#, openssl
, pkg-config
, stdenv
}:

# VLC does not know where the vlc-bittorrent package is installed.
# make sure to have something like:
#   environment.variables.VLC_PLUGIN_PATH = "${pkgs.vlc-plugin-pipewire}";

stdenv.mkDerivation (finalAttrs: {
  pname = "vlc-plugin-pipewire";
  version = "3";

  src = fetchGit {
    url = "https://git.remlab.net/gitweb/?p=vlc-plugin-pipewire.git";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
#    autoconf-archive
#    autoreconfHook
    libvlc
    pipewire
    pkg-config
  ];

  buildInputs = [
    libvlc
#    openssl
  ];

  strictDeps = true;

  # It's a library, should not have a desktop file
  postFixup = ''
    rm -r $out/share/
  '';

  meta = with lib; {
    description = "A PipeWire plugin for VLC";
    homepage = "https://www.remlab.net/vlc-plugin-pipewire/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ ];
  };
})
