# Homezone NixOS k3s

## New Nodes

### Install NixOS

Follow guides:
- https://nixos.org/manual/nixos/stables/index.html#sec-installation
- https://nixos.wiki/wiki/NixOS_Installation_Guide

Run normal installation and be sure to copy `hardware-configuration.nix` to a safe place.

### Copy Keys

Mount USB and copy
- github ssh key
- homezone ssh key
- age key

### Pull Repo
Add the github ssh key

```
eval $(ssh-agent)
ssh-add /etc/ssh/<github key>
```

Pull repo to /etc/nixos/

### Add Node Config

Copy
- hardware-configuration.nix -> nodes/<node-name>-hardware.nix

Add
- nodes/<node-name>.nix

Update
- outputs/nixos-conf.nix
- nodes.nix

Be sure to set the proper `networking.hostName` in `<node-name>.nix` and use the networking interface output by `ip a`.

### Update Secrets

Run `ssh-to-age` on the public host ssh key and add it to `.sops.yml`, then updatekeys for `secrets.enc.yml`.
```
sops updatekeys secrets.enc.yml
```
