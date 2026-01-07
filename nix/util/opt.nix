{ pkgs, ... }:
{
  jdks =
    with pkgs;
    let
      override = (
        pname:
        pname.override {
          enableJavaFX = true;
          openjfx_jdk = pkgs.openjfx.override { withWebKit = true; };
        }
      );
    in
    [
      (override openjdk)
      # (override jdk24)
      # (override jdk25)
      (override jdk17)
      # (override jdk24_headless)
      # (override jdk25_headless)
      graalvmPackages.graalvm-ce
      # temurin-bin-24
      temurin-bin-25
      temurin-bin-21
      temurin-bin-8
      temurin-bin-17
    ];
}
