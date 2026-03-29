# tycho

Lenovo ThinkPad T14 Gen 3 running NixOS with Hyprland desktop.

## Hardware

- **Platform**: x86_64-linux
- **CPU**: Intel (kvm-intel support)
- **Storage**: NVMe SSD (`/dev/nvme0n1`)
- **Connectivity**: Thunderbolt, USB 3.0, WiFi, Ethernet
- **Bootloader**: systemd-boot (EFI)

## Storage Layout

LUKS + LVM + BTRFS:

- **Boot**: 512M EFI (vfat)
- **Encrypted volume**: LUKS on remaining disk
- **LVM**:
  - 34GB swap (hibernation support)
  - Remaining → BTRFS
- **BTRFS subvolumes** (zstd compression): `/`, `/nix`, `/home`

## Services & Features

| Service | Config |
|---------|--------|
| Hyprland | [home-manager/common/features/desktop](../../../home-manager/common/features/desktop/) |
| greetd (tuigreet) | [hosts/common/optional/greetd.nix](../../common/optional/greetd.nix) |
| Hyprlock / Hypridle | [home-manager/common/features/desktop](../../../home-manager/common/features/desktop/) |
| Tailscale | [hosts/common/nixos/tailscale.nix](../../common/nixos/tailscale.nix) |
| OpenSSH | [hosts/common/nixos/openssh.nix](../../common/nixos/openssh.nix) |
| op-connect-secrets | [hosts/nixos/tycho/secrets.nix](secrets.nix) |
| YubiKey | [hosts/common/nixos/default.nix](../../common/nixos/default.nix) |

### Desktop

- **WM**: Hyprland
- **Terminal**: Ghostty
- **Launcher**: Rofi (wayland)
- **Bar**: Waybar
- **Color Scheme**: Tokyo Night Dark
- **Lock**: Hyprlock + Hypridle

### Dev Tools

- Kubernetes: k9s, kubectl
- nix-ld-vscode for VS Code compatibility
- YubiKey tools: yubioath-flutter, yubikey-manager
- 1Password GUI + CLI
- Claude Code

## Secrets

System-level (op-connect-secrets, fetched from nauvoo's Connect server at `10.1.30.100:8080`):
- `tailscaleKey` → `/run/opnix/tailscale-key`

User-level (opnix home-manager):
- Shell environment variables (`~/.config/shell-secrets/env`)

Bootstrap token (manually placed, never managed by Nix):
- `/etc/op-connect-token` — Connect server access token (see Bootstrap step 4)

## Build

```bash
nh os switch
# or
sudo nixos-rebuild switch --flake .#tycho
```

## Bootstrap

Fresh NixOS install:

### 1. Disk setup

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/nixos/tycho/disko-config.nix
```

### 2. Install

```bash
sudo nixos-install --flake .#tycho
```

### 3. First boot

```bash
cd /etc/nixos
sudo git clone git@github.com:Deatrin/dotfiles.git .
sudo chown -R deatrin:users .
nh os switch
```

### 4. Place op-connect token

tycho fetches secrets from nauvoo's 1Password Connect server — no local opnix needed.
Place the Connect token manually (nauvoo must be reachable at `10.1.30.100:8080`):

```bash
sudo install -m600 /dev/stdin /etc/op-connect-token
# paste the Connect token, then Ctrl+D
```

Then rebuild to provision secrets:

```bash
nh os switch
```

### 5. Post-install

```bash
# Atuin history sync
atuin login \
  --username $(op item get "atuin" --fields label=username) \
  --password $(op item get "atuin" --fields label=password) \
  --key "$(op item get "atuin" --fields label=key)"
atuin import auto
atuin sync -f

# Kubeconfig
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```

## Troubleshooting

### YubiKey GPG issues

```bash
gpg-connect-agent updatestartuptty /bye
```

### Secrets not provisioning

tycho uses `op-connect-secrets` pointing to nauvoo. `opnix-secrets.service` is a compatibility shim that delegates to it.

```bash
sudo systemctl status op-connect-secrets.service
sudo journalctl -u op-connect-secrets.service -n 30 --no-pager
sudo ls -la /run/opnix/
```

Common causes:
- `/etc/op-connect-token` missing — see Bootstrap step 4
- nauvoo not reachable at `10.1.30.100:8080` — check network/Tailscale

### Remote install (nixos-anywhere)

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#tycho root@<ip>
```
