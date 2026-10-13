# VMtemplate

Quick-deploy NixOS VM template for spinning up new VMs on Proxmox.

## Purpose

A minimal NixOS configuration used as a starting point for new VMs. Clone this directory and customize for a new host.

## Usage

### 1. Copy the template

```bash
cp -r hosts/VMtemplate hosts/nixos/<new-hostname>
```

### 2. Add to flake/hosts.nix

```nix
nixosHosts = {
  myNewVm = {
    system = "x86_64-linux";
    modules = [../hosts/nixos/myNewVm];
  };
};
```

### 3. Generate hardware config

Boot the VM from a NixOS ISO, then:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/nixos/myNewVm/disko-config.nix

sudo nixos-install --flake .#myNewVm
```

### 4. First boot

```bash
cd /etc/nixos
sudo git clone git@github.com:Deatrin/dotfiles.git .
sudo chown -R deatrin:users .
nh os switch
```

### 5. Secrets (op-connect)

Secrets are fetched from nauvoo's 1Password Connect server (see `secrets.nix`). Place the Connect token, then switch again:

```bash
sudo install -m600 /dev/stdin /etc/op-connect-token   # paste the token, then Ctrl+D
nh os switch
```

Add any per-host secrets (e.g. an Attic pull token) to `secrets.nix` with camelCase names.

## Notes

- Uses disko for declarative disk partitioning (see `disko-config.nix`)
- SaltStack master can be enabled via `hosts/common/optional/salt.nix`
- For production container hosts, see [nauvoo](../nixos/nauvoo/README.md) as a reference
