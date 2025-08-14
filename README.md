## Minecraft server configuration
System configuration using nixos-anywhere to deploy the basis of my Minecraft server

Requires an x86_64 VM with 8GiB of RAM to spare for Minecraft (so, ~10+), plus all the other nixos-anywhere requirements.

First-time setup:
- ensure the user you connect to the host as has password-less sudo enabled pre-install. that usually requires using visudo to change the end of the config like so:
  ```diff
  # User privilege specification
  root    ALL=(ALL:ALL) ALL

  - # Members of the admin group may gain root privileges
  - %admin  ALL=(ALL) ALL
  + # Allow members of group sudo to execute any command
  + %sudo   ALL=(ALL:ALL) ALL

  - # Allow members of group sudo to execute any command
  - %sudo   ALL=(ALL:ALL) ALL
  + # Members of the admin group may gain root privileges
  + %admin  ALL=(ALL) NOPASSWD:ALL

  # See sudoers(5) for more information on "#include" directives:

  #includedir /etc/sudoers.d
  ```
- probe hardware requirements
  `nix run github:nix-community/nixos-anywhere -- --flake .#ewangreen --env-password --target-host <user@host -p port> --generate-hardware-config nixos-facter ./facter.json`

To deploy/update:
- initialize or update plugins; like a "plugins.lock"
  `nix run github:BatteredBunny/nix-minecraft-plugin-upgrade -- --loader paper --game-version 1.21.7 --project coreprotect --project worldedit --project multiverse-core --project multiverse-inventories --project  multiverse-signportals > plugins.nix`
- install; test first by appending `--vm-test`
  `nix run github:nix-community/nixos-anywhere -- --flake .#ewangreen --env-password <user@host -p port>`

To connect (self-explanatory); `ssh -i <pubkey specified in config> <minecraft@host -p port>`
