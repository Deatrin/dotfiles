# Install and troubleshooting

## Fresh Install

starting on a fesh machine booted to nixOS live image

boot into the installer and connect to internet

clone this repo

create secret at /tmp/secret.key

```shell
echo 'my-secret' > /tmp/secret.key
```

```shell
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/razerback/disko-config.nix
```

```shell
sudo nixos-install --flake .#MACHINE_NAME
```

## fix yubikey

```shell
gpg-connect-agent updatestartuptty /bye
```

## nixos anywhere commands

```shell
nix run github:nix-community/nixos-anywhere -- --flake .#tachi root@<ip of box>
```

```shell
nix run github:nix-community/nixos-anywhere -- --flake .#tachi --generate-hadware-config nixos-generate-config ./hosts/tachi/hardware-configuration.nix root@<ip of box>
```
