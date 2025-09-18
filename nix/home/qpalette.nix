{
  config,
  pkgs,
  util,
  ...
}:
let
  col = config.lib.stylix.colors;
  h2d = util.hexColorToDecimalTriplet;
  dummy = "255,0,0";
  palette = ''
    [Appearance]
    color_scheme_path=${pkgs.writeText "stylix-palette" ''
      [ColorScheme]
      active_colors=#ff${col.base07}, #ff${col.base02}, #ff${col.base07}, #ff${col.base03}, #ff171717, #ff3c3c3c, #ff${col.base07}, #ff${col.base0D}, #ff${col.base06}, #ff${col.base02}, #ff${col.base01}, #ff${col.base00}, #ff${col.base0D}, #ff${col.base02}, #ff${col.base0D}, #ff${col.base0E}, #ff${col.base02}, #ff${col.base06}, #ff${col.base03}, #ff${col.base05}, #ff${col.base04}
      disabled_colors=#ff${col.base07}, #cd${col.base02}, #cd${col.base07}, #cd${col.base03}, #cd171717, #cd3c3c3c, #cd${col.base07}, #cd${col.base0D}, #cd${col.base06}, #cd${col.base02}, #cd${col.base01}, #cd${col.base00}, #cd${col.base0D}, #cd${col.base02}, #cd${col.base0D}, #cd${col.base0E}, #cd${col.base02}, #cd${col.base06}, #cd${col.base03}, #cd${col.base05}, #cd${col.base04}
      inactive_colors=#ff${col.base07}, #ff${col.base02}, #ff${col.base07}, #ff${col.base03}, #ff171717, #ff3c3c3c, #ff${col.base07}, #ff${col.base0D}, #ff${col.base06}, #ff${col.base02}, #ff${col.base01}, #ff${col.base00}, #ff${col.base0D}, #ff${col.base02}, #ff${col.base0D}, #ff${col.base0E}, #ff${col.base02}, #ff${col.base06}, #ff${col.base03}, #ff${col.base05}, #ff${col.base04}
    ''}

    custom_palette=true
    icon_theme=Yaru-sage-dark
    standard_dialogs="XDG Desktop Portal"
    style=darkly

  '';
in
{
  home.packages = with pkgs; [
    darkly-qt5
    darkly
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct,qt5ct";
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
  };

  xdg.configFile."qt5ct/qt5ct.conf".text = palette;
  xdg.configFile."qt6ct/qt6ct.conf".text = palette;
  xdg.configFile."kdeglobals".text = ''
    [ColorEffects:Disabled]
    Color=${h2d col.base00}
    ColorAmount=0.5
    ColorEffect=3
    ContrastAmount=0.5
    ContrastEffect=0
    IntensityAmount=0
    IntensityEffect=0

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=${h2d col.base01}
    ColorAmount=0.4
    ColorEffect=3
    ContrastAmount=0.4
    ContrastEffect=0
    Enable=true
    IntensityAmount=-0.2
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=${dummy}
    BackgroundNormal=${dummy}
    DecorationFocus=${h2d col.base0D}
    DecorationHover=${h2d col.base0D}
    ForegroundActive=${dummy}
    ForegroundInactive=${dummy}
    ForegroundLink=${dummy}
    ForegroundNegative=${dummy}
    ForegroundNeutral=${dummy}
    ForegroundNormal=${dummy}
    ForegroundPositive=${dummy}
    ForegroundVisited=${h2d col.base0E}

    [Colors:Complementary]
    BackgroundAlternate=${dummy}
    BackgroundNormal=${dummy}
    DecorationFocus=${h2d col.base0D}
    DecorationHover=${h2d col.base0D}
    ForegroundActive=${dummy}
    ForegroundInactive=${dummy}
    ForegroundLink=${dummy}
    ForegroundNegative=${dummy}
    ForegroundNeutral=${dummy}
    ForegroundNormal=${dummy}
    ForegroundPositive=${dummy}
    ForegroundVisited=${h2d col.base0E}

    [Colors:Selection]
    BackgroundAlternate=${dummy}
    BackgroundNormal=${dummy}
    DecorationFocus=${h2d col.base0D}
    DecorationHover=${h2d col.base0D}
    ForegroundActive=${dummy}
    ForegroundInactive=${dummy}
    ForegroundLink=${dummy}
    ForegroundNegative=${dummy}
    ForegroundNeutral=${dummy}
    ForegroundNormal=${h2d col.base00}
    ForegroundPositive=${dummy}
    ForegroundVisited=${h2d col.base0E}

    [Colors:Tooltip]
    BackgroundAlternate=${dummy}
    BackgroundNormal=${dummy}
    DecorationFocus=${h2d col.base0D}
    DecorationHover=${h2d col.base0D}
    ForegroundActive=${dummy}
    ForegroundInactive=${dummy}
    ForegroundLink=${dummy}
    ForegroundNegative=${dummy}
    ForegroundNeutral=${dummy}
    ForegroundNormal=${dummy}
    ForegroundPositive=${dummy}
    ForegroundVisited=${h2d col.base0E}

    [Colors:View]
    BackgroundAlternate=${dummy}
    BackgroundNormal=${dummy}
    DecorationFocus=${h2d col.base0D}
    DecorationHover=${h2d col.base0D}
    ForegroundActive=${dummy}
    ForegroundInactive=${dummy}
    ForegroundLink=${dummy}
    ForegroundNegative=${dummy}
    ForegroundNeutral=${dummy}
    ForegroundNormal=${dummy}
    ForegroundPositive=${dummy}
    ForegroundVisited=${h2d col.base0E}

    [Colors:Window]
    BackgroundAlternate=${dummy}
    BackgroundNormal=${h2d col.base01}
    DecorationFocus=${h2d col.base0D}
    DecorationHover=${h2d col.base0D}
    ForegroundActive=${dummy}
    ForegroundInactive=${dummy}
    ForegroundLink=${dummy}
    ForegroundNegative=${dummy}
    ForegroundNeutral=${dummy}
    ForegroundNormal=${h2d col.base06}
    ForegroundPositive=${h2d col.base06}
    ForegroundVisited=${h2d col.base0E}

    [General]
    ColorScheme=stylix
    Name=stylix
    shadeSortColumn=true

    [KDE]
    contrast=0

    [WM]
    activeBackground=${h2d col.base02}
    activeBlend=${h2d col.base07}
    activeForeground=${h2d col.base06}
    inactiveBackground=${h2d col.base01}
    inactiveBlend=${h2d col.base04}
    inactiveForeground=${h2d col.base05}
  '';
}
