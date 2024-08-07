# shit

## NixOS config

For the 2FA key, pam_u2f depends on the existence of `/etc/u2f_mappings` at run time. Without it, it'll fall back to password auth.
```
pamu2fcfg > /etc/u2f_mappings
```

Build config
```
sudo nixos-rebuild --flake .#HOSTNAME build
```    

Hostnames:
- [x] Desktop (`machine`)
- [ ] Laptop (`elbozo`)
- [ ] Server (`slave`)
