{ pkgs, ... }:
{
  programs.gamescope = {
    enable = true;
    capSysNice = true;
    args = [
      "--rt"
    ];
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
