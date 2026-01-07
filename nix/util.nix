# utility library; "lib" was taken
{
  secrets,
  root ? null,

  # provide for general usage (inside a module)
  pkgs ? null, # architecture specific packages
  config ? null,

  # provide when using top-level APIs (outside a module, e.g., systems.nix)
  inputs ? null,
  ...
}:
rec {
  # util.style
  # helpers for style-related functions
  style = (import ./util/style.nix) {};

  # util.commands
  # refer to executables absolutely inside scripts
  commands = (import ./util/commands.nix) { inherit pkgs; };

  # util.scripts, util.script
  # these scripts can be retrieved with util.script "name"
  s = (import ./util/scripts.nix) { inherit config pkgs commands root style; };
  inherit (s) scripts script;

  # util.systems
  # helpers for creating Nix modules
  systems = (import ./util/systems.nix) { inherit inputs secrets; };

  # util.opt
  # common definitions for irregularly packaged software
  opt = (import ./util/opt.nix) { inherit pkgs; };

  # util.etc
  # oddball functions
  etc = (import ./util/etc.nix) { inherit pkgs secrets; };
}
