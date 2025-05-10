# Bootstrapping NixOS on 'tycho'

It is installed with the NixOS iso installation media.  These are the steps initially taken to install NixOS, though once the config is setup it can just be re-used for future re-installs if needed. This assumes you have booted into a NixOS install image from a USB stick and that we will be using systemd-boot.  Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

## Clone this repo

Were going to need this on the host machine

```shell
git clone https://github.com/Deatrin/dotfiles.git
```

## Disk Setup

We use disko to partition the disk to make ready for install. In this case we are encrypting

Create secret at /tmp/secret.key / this is used as the key needed to boot the machine

```shell
echo '<my-secret>' > /tmp/secret.key
```

```shell
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/tycho/disko-config.nix
```

## NixOS Install

Once the disk is partitioned we run the install using the flake

```shell
sudo nixos-install --flake .#tycho
```

## First Run

This is where I bring down the git repo so I can work on it but most importantly I can easily switch configs:

```shell
cd /etc/nixos
git clone git@github.com:Deatrin/dotfiles.git .
chown -R deatrin:users .
```

Then we should be able to update the nixos-configuration repo in github and just pull/rebuild as needed on the machine.

```shell
sudo sh -c "cd /etc/nixos && git pull && nixos-rebuild switch --flake .#tycho"
```

## Things that need secrets

### 1Password bootstrapping auth

```shell
eval $(op signin --account <redacted>.1password.com)
```

### atuin login

```shell
atuin login --username $(op item get "atuin" --fields label=username) --password $(op item get "atuin" --fields label=password) --key "$(op item get "atuin" --fields label=key)"
atuin import auto
atuin sync -f
```

### kubeconfig

```shell
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```

## Troubleshooting

### fix yubikey

```shell
gpg-connect-agent updatestartuptty /bye
```

## TODO see if these commands work while using linux they were not happy when trying to run from darwin

### nixos anywhere commands

```shell
nix run github:nix-community/nixos-anywhere -- --flake .#tycho root@<ip of box>
```

```shell
nix run github:nix-community/nixos-anywhere -- --flake .#tycho --generate-hadware-config nixos-generate-config ./hosts/tycho/hardware-configuration.nix root@<ip of box>
```
