{ pkgs ? import <nixpkgs> { } }:

(pkgs.buildFHSEnv {
  name = "qtcreator-env";

  targetPkgs = pkgs: (with pkgs; [
    qtcreator
    
    # General
    fish
    pkg-config
    stdenv.gcc
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
    gdb
    cmake
    ninja

    clangd
    clang-format
    clang-tidy

    cmake-format
    
    qt5.qtbase.bin
    qt5.qtbase.dev
    qt5.qttools.bin
    qt5.qttools.dev
    qt5.qmake
    qt6.qtbase.bin
    qt6.qtbase.dev
    qt6.qttools.bin
    qt6.qttools.dev
    qt6.qmake
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

  runScript = "nohup ${pkgs.lib.getExe pkgs.qtcreator}  2>/dev/null 1>&2 &; exec ${pkgs.lib.getExe pkgs.fish";
}).env
