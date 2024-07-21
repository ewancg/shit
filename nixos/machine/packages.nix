{ pkgs, config, ... }:
with pkgs;
let
  # System packages
  system = [
    # Nix
    nix-index
    nixpkgs-fmt
    nil

    # Essential libraries and utilities
    openssl
    gnupg
    wget
    git
    lshw
    pciutils
    udisks

    # Wine
    wine64
    winetricks
    wineWowPackages.staging
    wineWowPackages.waylandFull

    # Other
    openrgb
    # solaar # broken on 7 21 24
    logiops
  ];

  # Packages involved/integrated in my terminal workflow
  termish = with pkgs; [
    alacritty
    tmux
    fish

    fd
    fzf

    neovim

    imagemagick

    # system wide rust... one day
    # (callPackage ../misc/rustup.nix {})
  ];

  # Apps (move to home.nix?)
  apps = with pkgs; [
    # Communication
    (symlinkJoin {
      name = "my-discord";

      paths = [
        vesktop
      ];

      postBuild = ''
        for size in 32 64 128 256 512 1024; do
          dim="$size"x"$size"
          rm $out/share/icons/hicolor/"$dim"/apps/vesktop.png
          ${lib.getExe imagemagick} ${../misc/discord.png} -resize "$dim" $out/share/icons/hicolor/"$dim"/apps/vesktop.png
        done

        rm $out/share/applications/vesktop.desktop
        cp ${../misc/discord.desktop} $out/share/applications/vesktop.desktop
      '';
    })
    teamspeak_client

    # "Task manager"
    mission-center

    # Gaming
    (prismlauncher.override { withWaylandGLFW = true; })
    # Steam - Fix NVIDIA Vulkan driver bug on 555.58
    (steam.override {
      extraProfile = ''
        export VK_ICD_FILENAMES=${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.json:${config.hardware.nvidia.package.lib32}/share/vulkan/icd.d/nvidia_icd32.json:$VK_ICD_FILENAMES
      '';
    })

    # Multimedia
    vlc
    gimp

    # Productivity, misc.
    qpwgraph
    pwvucontrol
    obsidian
    gnome-disk-utility
    xfce.thunar
  ];
in
{
  # Fonts
  fonts.packages = with pkgs; [
    (callPackage ../misc/segoe-ui-variable.nix { })
    noto-fonts
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    corefonts
    vistafonts
  ];

  # Run non-Nix binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;

  # Other
  environment.systemPackages = with pkgs; [
    # Theming
    gradience
    adw-gtk3
    libsForQt5.qtstyleplugin-kvantum

    normcap

    wl-clipboard
    wofi
    xsel
  ] ++ system ++ termish ++ apps;
}
