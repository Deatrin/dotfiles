# tycho - Lenovo T14 G3 NixOS Configuration

## Hardware Specifications

- **Model**: Lenovo ThinkPad T14 Gen 3
- **CPU**: Intel (with kvm-intel support)
- **Storage**: NVMe SSD (/dev/nvme0n1)
- **Connectivity**: Thunderbolt, USB 3.0, WiFi, Ethernet
- **Bootloader**: systemd-boot with EFI

## System Configuration

### Storage Layout (Disko + LUKS + LVM + BTRFS)

- **Boot Partition**: 512M EFI partition (vfat)
- **Encrypted Volume**: LUKS encryption on remaining disk
- **LVM Setup**:
  - 34GB swap (with resume support for hibernation)
  - Remaining space for BTRFS
- **BTRFS Subvolumes** (with zstd compression):
  - `/` (root)
  - `/nix`
  - `/home`

## Enabled Services & Features

### System Services

| Service | Description | Config Location |
|---------|-------------|-----------------|
| Podman | Container runtime (rootless) | [hosts/common/optional/podman.nix](../../common/optional/podman.nix) |
| Hyprland | Wayland compositor | [home-manager/common/features/desktop](../../../home-manager/common/features/desktop/) |
| XWayland | X11 compatibility layer | [hosts/common/optional/xwayland.nix](../../common/optional/xwayland.nix) |
| Tailscale | VPN for remote access | [hosts/common/nixos/tailscale.nix](../../common/nixos/tailscale.nix) |
| OpenSSH | Remote shell access | [hosts/common/nixos/openssh.nix](../../common/nixos/openssh.nix) |
| YubiKey Support | Hardware authentication | [hosts/common/nixos/default.nix](../../common/nixos/default.nix) |
| Opnix Secrets | 1Password integration | [hosts/nixos/tycho/secrets.nix](secrets.nix) |
| Custom Fonts | Font configurations | [hosts/common/optional/font.nix](../../common/optional/font.nix) |
| Reboot Required | Update notifier | [hosts/common/optional/reboot-required.nix](../../common/optional/reboot-required.nix) |

### Desktop Environment

- **Window Manager**: Hyprland (Wayland compositor)
- **Terminal**: Ghostty
- **Application Launcher**: Rofi (wayland fork)
- **Color Scheme**: Dracula (via nix-colors)
- **Additional Tools**: waybar, swaylock, hyprpaper

### Development Tools

- Kubernetes tools via home-manager: k9s, kubectl
- nix-ld-vscode for VS Code compatibility
- YubiKey tools: yubioath-flutter, yubikey-manager
- 1Password GUI and CLI
- Claude CLI tool

### Secrets Management

System-level opnix secrets:
- **tailscaleKey**: Tailscale authentication key from op://nix_secrets/tailscale-key/key

User-level secrets via opnix:
- Shell environment variables (1Password personal vault)

### State Version

NixOS 23.11

## Building and Deployment

### Using nh (Recommended)

```shell
# NH_FLAKE is set to /etc/nixos in the environment
nh os switch
```

### Using nixos-rebuild

```shell
# From repository root
sudo nixos-rebuild switch --flake .#tycho

# From /etc/nixos (if repository is cloned there)
sudo nixos-rebuild switch --flake .#tycho
```

### Updating the Flake

```shell
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

## Bootstrap Installation

These steps are for fresh installation of NixOS on tycho. This assumes you have booted into a NixOS install image from a USB stick. Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

### 1. Clone this repo

```shell
git clone https://github.com/Deatrin/dotfiles-redux.git
cd dotfiles-redux
```

### 2. Disk Setup with Disko

Create the LUKS encryption key (this will be needed to boot the machine):

```shell
echo '<my-secret-passphrase>' > /tmp/secret.key
```

Run disko to partition and encrypt the disk:

```shell
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/nixos/tycho/disko-config.nix
```

### 3. NixOS Install

Install NixOS using the flake:

```shell
sudo nixos-install --flake .#tycho
```

### 4. First Boot Setup

After rebooting into the new system, clone the repository to /etc/nixos for easy management:

```shell
cd /etc/nixos
sudo git clone git@github.com:Deatrin/dotfiles-redux.git .
sudo chown -R deatrin:users .
```

Now you can update configurations by pulling from git and rebuilding:

```shell
sudo sh -c "cd /etc/nixos && git pull && nixos-rebuild switch --flake .#tycho"
```

## Post-Installation Setup

### Opnix Setup

Setup opnix for 1Password secrets management:

```shell
# Set opnix service account token
sudo opnix token set
# Paste your 1Password service account token when prompted

# Rebuild to provision secrets
sudo nixos-rebuild switch --flake .#tycho
```

### 1Password CLI Authentication (for manual secret access)

Sign in to 1Password for manual secret access:

```shell
eval $(op signin --account <redacted>.1password.com)
```

### Atuin Shell History Sync

Configure and sync shell history with Atuin:

```shell
atuin login --username $(op item get "atuin" --fields label=username) \
            --password $(op item get "atuin" --fields label=password) \
            --key "$(op item get "atuin" --fields label=key)"

atuin import auto
atuin sync -f
```

### Kubernetes Configuration

Set up kubeconfig from 1Password:

```shell
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```

## Troubleshooting

### YubiKey GPG Issues

If YubiKey GPG signing stops working, reset the startup TTY:

```shell
gpg-connect-agent updatestartuptty /bye
```

### Secrets Management

Secrets are managed using [opnix](https://github.com/mrjones2014/opnix) for 1Password integration. Secret definitions are in `hosts/nixos/tycho/secrets.nix`.

**System-level secrets** (configured in secrets.nix):
- tailscaleKey: Provisioned automatically to `/run/opnix/tailscale-key`

**User-level secrets** (configured in home-manager):
- Shell environment variables: Provisioned to `~/.config/shell-secrets/env`

**Important**: Secret names must be camelCase (e.g., `tailscaleKey` not `tailscale-key`).

To verify secrets are provisioned:

```shell
# Check system secrets
sudo ls -la /run/opnix/

# Check user secrets
ls -la ~/.config/shell-secrets/
```

For detailed opnix documentation, see [CLAUDE.md](../../../CLAUDE.md#secrets-management-opnix).

## Advanced: Remote Installation with nixos-anywhere

For automated remote installation (useful for reinstalls):

```shell
# Basic remote installation
nix run github:nix-community/nixos-anywhere -- --flake .#tycho root@<ip-address>

# Generate hardware config during remote installation
nix run github:nix-community/nixos-anywhere -- \
  --flake .#tycho \
  --generate-hardware-config nixos-generate-config ./hosts/nixos/tycho/hardware-configuration.nix \
  root@<ip-address>
```

**Note**: Ensure the LUKS key file is accessible during remote installation.
