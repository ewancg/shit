{ pkgs ? import <nixpkgs> { } }:

(pkgs.buildFHSEnv {
  name = "qtcreator-fhs";

  targetPkgs = pkgs: (with pkgs; [
    qtcreator

    # General
    fish
    pkg-config
    curl
    libnotify
    pcre
    python3
    sqlite

    ffmpeg
    x264

    mold

    # Rust
    cargo

    # CPP
    stdenv.cc
    gcc
    gdb
    cmake
    ninja

    clang-tools
    cmake-format

    qt5.qtbase.bin
    qt5.qtbase.dev
    qt5.qttools.bin
    qt5.qttools.dev
    qt5.qmake
    qt6.full
    freetype
    libGLU
    libogg
    opusfile
    SDL2
    wavpack
    vulkan-loader
    vulkan-headers
    glslang
    spirv-tools
  ]);

  runScript = "nohup ${pkgs.lib.getExe pkgs.qtcreator}  2>/dev/null 1>&2 & exec ${pkgs.lib.getExe pkgs.fish}";
}).env
