{pkgs, ...}:
{    # for nix-index command not found integration
    programs.command-not-found.enable = false;

    # Run non-Nix binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.package = pkgs.nix-ld-rs;
}
