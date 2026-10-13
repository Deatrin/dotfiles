# VMtemplate

Starting point for a new NixOS host (Proxmox VM or bare metal). It isn't a real host and isn't listed in `flake/hosts.nix`.

Out of the box it gives you the shared NixOS base (`hosts/common/nixos`), the `deatrin` user with home-manager, Tailscale, and op-connect secrets from nauvoo, with DHCP networking and no optional features.

## 1. Copy the template

From a checkout of this repo, with `<host>` as the new hostname:

```bash
cp -r hosts/nixos/VMtemplate hosts/nixos/<host>
cp home-manager/nixos/deatrin_vmtemplate.nix home-manager/nixos/deatrin_<host>.nix
```

Then edit:

- `hosts/nixos/<host>/default.nix`: set `networking.hostName = "<host>";` (it must match the home-manager file name). Turn on features under `dotfiles = { ... };`, and set a static IP if wanted.
- `hosts/nixos/<host>/disko-config.nix`: set the disk `device` (e.g. `/dev/sda` or `/dev/vda` on Proxmox).
- `home-manager/nixos/deatrin_<host>.nix`: turn on home-manager features if any.

## 2. Add it to `flake/hosts.nix`

```nix
nixosHosts = {
  <host> = {
    system = "x86_64-linux";
    modules = [../hosts/nixos/<host>];
  };
};
```

Run `jj st` so jj picks up the new files, then check it evaluates:

```bash
nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
```

## 3. Install

Boot the NixOS ISO. Clone over HTTPS from the public GitHub mirror (it needs no keys), partition, generate the hardware config, and install:

```bash
git clone https://github.com/Deatrin/dotfiles.git /tmp/dotfiles && cd /tmp/dotfiles
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/nixos/<host>/disko-config.nix
sudo nixos-generate-config --no-filesystems --show-hardware-config > hosts/nixos/<host>/hardware-configuration.nix
sudo nixos-install --flake .#<host>
```

Commit and push the new host (including its generated `hardware-configuration.nix`) from your usual machine.

## 4. First boot

```bash
sudo git clone https://github.com/Deatrin/dotfiles.git /etc/nixos
sudo chown -R deatrin:users /etc/nixos
```

Switch the remote to Forgejo once SSH keys are in place, since Forgejo is the primary remote.

## 5. Secrets (op-connect)

Secrets are fetched from nauvoo's 1Password Connect server (see `secrets.nix`). Until the token exists, every switch prints a warning and Tailscale won't authenticate. Place the token, then switch:

```bash
sudo install -m600 /dev/stdin /etc/op-connect-token   # paste the token, then Ctrl+D
nh os switch
```

Add per-host secrets (e.g. an Attic pull token) to `secrets.nix`, with camelCase names.

## Notes

- Disk layout is declarative via disko (`disko-config.nix`).
- Optional features are aspects in `aspects/nixos/` (e.g. `dotfiles.salt.enable` for the SaltStack master).
- For a container host, see [nauvoo](../nauvoo/README.md).
