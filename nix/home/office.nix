{ pkgs, ... }:
with pkgs;
let
  vlc-plugin-pipewire = callPackage ../misc/vlc-plugin-pipewire/default.nix { };

  # for Wayland
  my-vlc = (symlinkJoin {
    name = "my-vlc";
    paths = [ vlc ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vlc \
        --unset DISPLAY
    '';
  });

  my-obs = (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
    ];
  });
in
{
  home.packages = with pkgs; [
    # Communication
    teams-for-linux
    thunderbird
    slack

    # Multimedia
    mpv
    my-vlc
    spotify
    vlc-plugin-pipewire
    photoflare

    easyeffects
    pwvucontrol
    qpwgraph

    my-obs
    normcap # OCR

    blueman
    firefox
    fsearch
    gimp
    nautilus
    obsidian

    zed-editor
    jetbrains.rust-rover
  ];

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ firefox pkg-config ]);
  };
}
