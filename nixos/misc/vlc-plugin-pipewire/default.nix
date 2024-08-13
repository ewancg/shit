{ lib
, pipewire
, libvlc
, fetchurl
, pkg-config
, stdenv
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vlc-plugin-pipewire";
  version = "3";

  src = fetchurl {
    url = "https://www.remlab.net/files/vlc-plugin-pipewire/vlc-plugin-pipewire-v3.tar.xz";
    hash = "sha256-26QQt8EfKVpuoii//u8xz1NPZZreddFecTQwhXcSTns=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libvlc
    pipewire
  ];

  strictDeps = true;

  installPhase = ''
    mkdir -p $out/lib
    cp libaout_pipewire_plugin.so $out/lib
  '';

  meta = with lib; {
    description = "A PipeWire plugin for VLC";
    homepage = "https://www.remlab.net/vlc-plugin-pipewire/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ ];
  };
})
