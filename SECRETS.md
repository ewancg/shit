## Secrets flake schema
This configuration uses an out-of-tree flake to keep track of information too sensitive to keep
statically in version control (e.g. online), but perfectly safe (or necessary) to keep unencrypted
on disk. Because the main flake refers to this one with the path type (as opposed to a url which
only supports git-tracked files in flakes), updates to this file will not be detected when you run
nixos-rebuild, so you'll have to run
```
nix flake update secrets
```
in order for changes to be reflected.

You must also change the main flake's canonical path to this one to reflect your configuration. If
you want to use a relative path instead, you need to enable impure evaluation mode (something that
I don't currently need).

The configuration expects a flake.nix following this format:

---

###### <small>*shit/secrets/flake.nix*</small>
```nix
{
  todo: automatically generate from real flake
  annotate definitions with "description" and pre-process to move description to comment above the initial definition
}
```
