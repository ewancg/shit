{ config
, pkgs
, ...
}:
{
  #config = lib.mkIf (cfg.enableSudoTouchId) {
  security.pam = {
    # enableSudoTouchIdAuth = true;
    services.sudo_local = {
      enable = true;
      touchIdAuth = true;
      reattach = true;
    };
  };
    
    environment.systemPackages = [
      pkgs.pam-reattach
    ];
    #environment.etc."pam.d/sudo_local" = {
    #  text = ''
    #    # auth       optional       ${pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    #    auth       sufficient     pam_tid.so
    #  '';
    #};
}
