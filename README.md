
# Minecraft server configuration
My NixOS system configuration for a remotely-managed Minecraft server.
Requires a host NixOS system with flakes enabled and a [nixos-anywhere compatible VM]() (x86_64 Linux with kexec).

## Table of Contents
[First-time setup](#first-time-setup)
- [Populating inputs](#populating-inputs)
- [First-time deployment](#initial-deployment)

[Maintenance](#maintenance)
- [Config changes](#config-changes)
- [Plugin configuration](#plugin-configuration)
- [Updating](#updating-rebuild)
- [Connecting](#connecting)

# First-time setup
## Populating Inputs
All obvious configuration options for the remote server will be sourced from an out-of-tree flake. Some options are sensitive & must not be tracked in git, so we treat the entire configuration as a secret. There's no way to retain pure evaluation mode unless using an absolute path, so you will have to adjust `flake.nix`'s `secrets` input to point to the location of your `secrets` flake via. path (e.g., `secrets.url = "path:/absolute/path/to/this/config/secrets"`). The flake should have the following schema:
```nix
{
  outputs = { self }: {
    secrets = {
      # Your SSH public key
      adminPubKey = "SSH pub key; string";
      minecraft = {
        memoryMiB = integer;
        gamePort = integer;
        rconPort = integer;
        rconPassword = "string";

        ops = {
          # Any amount of users
          UserName = "UUID; string"
          ...
        };

        whitelist = {
          # Any amount of users
          UserName = "UUID; string"
          ...
        };
      };

      # Required for EssentialsX Discord bridge
      discord = {
        applicationToken = "string";
        server = {
          id = "string";
          generalChannelId = "string";
          staffChannelId = "string";
          consoleChannelId = "string";
        };
      };

      # Storage backend for LuckPerms, with remote access
      postgres = {
        port = integer;
        user = "string";
        database = "string";
        password = "string";
      };
    };
  };
}
```
Whenever these inputs are changed, you need to manually update the main flake's inputs (the secrets flake will have no git repo or lockfile).
```
nix flake lock --update-input secrets
```

### Initial Deployment
#### Prerequisites
Passwordless sudo is required before NixOS can be remotely deployed. The following changes can be made on the remote server via. `visudo` (look near the bottom of the buffer it provides).
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
These nixos-anywhere commands require the remote user's password is set via. `SSHPASS`. If you're authenticating with a SSH key pair, you must set it to an empty string (`SSHPASS=''`) or remove `--env-password` from the invocations, otherwise they will fail with a segfault somewhere down the line (cool). It's best to export it if you're running these commands contiguously.

If you want to add plugins to the server, now is the time (refer to [plugin configuration](#plugin-configuration)).

#### Deployment
We will automatically detect as much of the hardware configuration as we can with nixos-facter. The resulting `facter.json` should be checked into version control, and is required for the derivation to build.
```
nix run github:nix-community/nixos-anywhere -- --flake .#ewangreen --env-password --target-host <user@host -p port> --generate-hardware-config nixos-facter ./facter.json
```
This is the best time to do a once-over of the actual .nix files if you need to change things not specified in the input flake. For example, Minecraft version changes, server properties & plugin configurations, and tunings for compatibility with a specific VPS host must be set there. You almost definitely want to change `disk.nix`.

The actual installation is distinct from the rebuild step. You can trigger installation with the following command; be careful not to accidentally call this when *upgrading*, or you will overwrite the world & Postgres database. You can test that the derivation runs on a local VM first by appending `--vm-test`, but this isn't indicative of whether the whole installation will succeed.
```
nix run github:nix-community/nixos-anywhere -- --flake .#ewangreen --env-password <user@host -p port>
```
Assuming everything went smoothly, your server should be up and running. Now refer to the maintenance section.

## Maintenance:

### Config Changes
Put input config changes into effect (explained in [populating inputs](#populating-inputs))
```
nix flake lock --update-input secrets
```

### Plugin Configuration
The following command will generate a `plugins.nix` with [nix-minecraft](https://github.com/infinidoge/nix-minecraft)-compatible definitions. It takes plugin names from Modrinth to create the plugin definitions used by the main config. The file also acts as a lockfile in that it specifies plugin versions and URLs.
```
nix run github:BatteredBunny/nix-minecraft-plugin-upgrade -- --loader paper --game-version 1.21.7 --project coreprotect --project worldedit --project multiverse-core --project multiverse-inventories --project multiverse-signportals --project essentialsx --project vault --project essentialsx-discord --project luckperms > plugins.nix
```

### Updating (rebuild)
A rebuild command would look like this. Remember to run this instead of `nixos-anywhere` when updating.
```
NIX_SSHOPTS="-p <port>" nixos-rebuild --flake .#ewangreen --target-host <host> --build-host <host>
```

### Connecting
This should be fairly self explanatory.
```
ssh -i <pubkey specified in config> <minecraft@host -p port>
```


<details open><summary>Runtime secrets (non-functional WIP)</summary>
Secrets (wip)
- create a SSH key pair if you want
  `ssh-keygen -t ed25519`
- generate age key for sops using your private key (more details https://github.com/Mic92/sops-nix?tab=readme-ov-file#deploy-example)
  `nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys`
  `gpg --full-generate-key`
- extract public key from new age key
  `age-keygen -y ~/.config/sops/age/keys.txt`
- add your public age key to `.sops.yaml`
  ```diff
  keys:
  + &admin_me <pubkey>
  creation_rules:
    - age:
      - *admin_me
  ```
- get public key for the remote machine
  `nix-shell -p ssh-to-age --run 'ssh-keyscan <-p port host> | ssh-to-age'`
- add the server's public key to `.sops.yaml`
  ```diff
  keys:
    + &server_mine <pubkey>
    creation_rules:
      - age:
        - *server_mine
  ```
- populate secrets
  using the command: `nix-shell -p sops --run "sops secrets.yaml"`
  to open an editor, where you will input: `rcon-password: <password>`
- whenever you add a new host, update the keys
  `nix-shell -p sops --run "sops updatekeys secrets.yaml"`
</details>
