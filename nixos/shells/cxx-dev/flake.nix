# { pkgs ? import <nixpkgs> {} }:
# {
#   outputs =
#     { nixpkgs, 
#     ... }:
#     let
#       system = "x86_64-linux";
#     in
#     {
#       devShells.${system}.default = pkgs.buildFHSEnv
#         {
#           stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
#         }
#         {
#           name = "ddnet-env";
# 
#           # ?
#           inputsFrom = [ pkgs.ddnet ];
# 
#           targetPkgs = with pkgs; [
#             fish
#             vscode-fhs
# 
#             # ?
#             # vulkan-validation-layers
#             # vulkan-tools 
#           ];
# 
#           runScript = ''
#             exec ${pkgs.lib.getExe pkgs.fish} -iC '
#             function fish_right_prompt 
#               set_color $fish_color_cwd
#               printf "*ddnet"
#               set_color normal
#             end'
#           '';
#         };
#     };
# }

{
  outputs =
    { nixpkgs
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixpkgs.config.allowUnfree = true;

      devShells.${system}.default = pkgs.mkShell.override
        {
          stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
        }
        {
          packages = with pkgs; [
            alsa.dev
            dbus.dev

            pkg-config

            vscode-fhs
            qtcreator
            fish

            pkgs.vulkan-validation-layers
            pkgs.vulkan-tools

          ];
          shellHook = ''
            exec ${pkgs.lib.getExe pkgs.fish} -iC '
            function fish_right_prompt 
              set_color $fish_color_cwd
              printf "*dev"
              set_color normal
            end'
          '';
        };
    };
}
