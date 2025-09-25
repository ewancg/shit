{ pkgs, ... }:
{
  programs.gamescope = {
    enable = true;
    capSysNice = false;
    #package = (
    #  pkgs.gamescope.overrideAttrs (old: {
    #    src = pkgs.fetchFromGitHub {
    #      owner = "ColinKinloch";
    #      repo = "gamescope";
    #      rev = "dont_want_no_scrgb";
    #      hash = "sha256-vEN5RdDLxlBG1VEqxe+7FOmHtLfck1/MfbL3LqItzzw=";
    #    };
    #  })
    #);
    #args = [
    #  "--rt"
    #];
  };

  environment.systemPackages = with pkgs; [
    gamescope
  ];

  # security.wrappers.gamescope = {
  #   source = "/run/current-system/sw/bin/gamescope";
  #   capabilities = "CAP_SYS_NICE=eip";
  #   owner = "root";
  #   group = "";
  # };
}
