# shit
This repository contains the Nix configurations for all of my use cases. The main branch contains
the configuration for my personal computers, and [this](https://github.com/ewancg/shit/tree/newpaperidk/README.md) branch contains my VPS config.
(with tools for administration of the host VM and the Minecraft instances it runs).

## Nix flake, NixOS/nix-darwin configurations
The main Nix configuration contains a unique output for each computer. It is written to accommodate
both NixOS and nix-darwin, to whatever extent makes sense.
  - `machine`: the NixOS config for my main desktop (Ryzen 9 7900X/RTX 4070 Ti SUPER/64GB DDR5).
  - `elbozo`: the NixOS config my personal laptop (Lenovo IdeaPad Flex 5, Ryzen 5 5500U/16GB DDR4).
  - `D430N0H49X`: you may find references to a config for a MacBook Pro I used at a previous job (M3 Pro/18GB shm/14x GPU). this is not a functional config

All of these configurations require some minor setup; sensitive things like passwords, private keys
and U2F keys are perfectly safe to keep on disk, but cannot be kept in version control as my config
is public. They are stored in a flake that lives in the `secrets` directory, which is consumed by
the main flake as an input in order to provide a namespace for such constants that will be imported
into the configuration derivations. See [SECRETS.md](SECRETS.md).


Much of the behavior could be could be adapted to be enabled with attributes from the secrets, but
the plumbing hasn't been implemented (and won't be, unless it has to). Currently the configurations
branch into system-specific configs by only importing certain files, and not by including all files
while gating their state behind an attribute (which is the standard). The design is from before I
thought to separate the system-specific logic from the meat of the config.
