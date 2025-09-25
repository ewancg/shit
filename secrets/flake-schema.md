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
  outputs = { self }: {
    secrets = {
      ## Local computer auth

      ## Hashed password definitions per-user. Generate these with `mkpasswd`. In the configuration
      ## they are placed at unique locations in the store because users...hashedPasswordFile takes
      ## precedence over all other password definition options.
      hashedPasswords = {
        "root" = String;
      };

      ## U2F key mappings. Generate these with `pamu2fcfg`. https://developers.yubico.com/pam-u2f
      ## "Central Authorization Mapping" (there is currently no user-specific mapping mechanism)
      u2fMappings = [String | Attrs];

      ## The string form is nice if you want to paste `pamu2fcfg` output directly.
      # u2fMappings = ''
      #     username:keyHandle,userKey,coseType,options
      #     ...
      # '';
      ## An attribute set is helpful for using the same key with multiple users, maybe with
      ## different options; it could also be used just for the sake of being idiomatic.
      # u2fMappings = {
      #   username = {
      #     keyHandle = String;
      #     userKey = String;
      #     coseType = String;
      #     options = String;
      #   };
      #   ...
      # };


      # --------------------


    };
  };
}
```
