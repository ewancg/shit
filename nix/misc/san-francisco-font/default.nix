{ stdenvNoCC
, lib
, fetchzip
, pkgs
,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "san-francisco";
  version = "0-unstable-2025-09-02";

  src = pkgs.fetchFromGitHub {
    owner = "AppleDesignResources";
    repo = "SanFranciscoFont";
    rev = "4923258ee500ebfce45d633817dc7c02df89bc40";
    hash = "sha256-fCIM90oocPh8jAXUk/eNpWvHxjyctomJLHIEkmuWhl4=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{fonts/opentype,licenses/san-francisco}
    for font in *.ttf; do
      ln -s ${finalAttrs.src}/"$font" $out/share/fonts/opentype/"$font"
    done

    runHook postInstall
  '';

  meta = {
    description = " The San Francisco font by Apple used in the Apple Watch, iOS 9, and OS X El Capitan. Originally found at https://developer.apple.com/watchos/download/";
    homepage = "https://github.com/AppleDesignResources/SanFranciscoFont";
    license = lib.licenses.unfree; # Guessing, haven't read what EULA allows
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
