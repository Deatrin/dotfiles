# nauvoo

High-performance VM configured as a media server with GPU passthrough for hardware transcoding.

## Hardware Specifications

- **Platform**: x86_64-linux (Virtual Machine)
- **CPU**: AMD with KVM support (kvm-amd)
- **GPU**: NVIDIA with proprietary drivers and container toolkit
- **Network**: Static IP 10.1.30.100/24
- **Storage**: NFS mount to 10.1.10.5:/volume1/Roci/Media_Storage

## Enabled Services & Features

### System Services

| Service | Description | Config Location |
|---------|-------------|-----------------|
| Docker | Container runtime with NVIDIA support | [hosts/common/optional/docker.nix](../../common/optional/docker.nix) |
| Plex | Media server with GPU transcoding | [hosts/common/optional/plex.nix](../../common/optional/plex.nix) |
| Jellyseerr | Media request management | [hosts/common/optional/jellyseerr.nix](../../common/optional/jellyseerr.nix) |
| VSCode Server | Remote development server | [hosts/common/optional/vscode-server.nix](../../common/optional/vscode-server.nix) |
| NFS Mount | Network storage at /mnt/nmedia | [hosts/nixos/nauvoo/default.nix](default.nix) |
| NVIDIA Drivers | GPU drivers with container support | [hosts/nixos/nauvoo/hardware-configuration.nix](hardware-configuration.nix) |
| Tailscale | VPN for remote access | [hosts/common/nixos/tailscale.nix](../../common/nixos/tailscale.nix) |
| OpenSSH | Remote shell access | [hosts/common/nixos/openssh.nix](../../common/nixos/openssh.nix) |
| Reboot Required | System update notifier | [hosts/common/optional/reboot-required.nix](../../common/optional/reboot-required.nix) |

### Desktop Environment

None - headless server configuration

### Development Tools

- Kubernetes tools via home-manager: k9s, kubectl
- nix-ld-vscode for VS Code compatibility

### Secrets Management

No system-level opnix secrets configured (media server doesn't require them currently).

User-level secrets via opnix:
- Shell environment variables (1Password servers vault)

## From Fresh Machine to Fully Configured

### Prerequisites

1. VM platform with:
   - AMD CPU virtualization support
   - NVIDIA GPU passthrough capability
   - Network access (static IP recommended)
2. NixOS ISO installation media
3. 1Password account with service account token
4. NFS server accessible at 10.1.10.5 (or update configuration)

### Installation Steps

#### Step 1: Boot from NixOS ISO

Boot the VM from NixOS installation media.

#### Step 2: Clone Repository

```bash
# Install git in live environment
nix-shell -p git

# Clone the repository
git clone https://github.com/Deatrin/dotfiles-redux.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

#### Step 3: Disk Setup with Disko

Partition the disk using the declarative disko configuration:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/nixos/nauvoo/disko-config.nix
```

This will automatically partition and format the disk according to the configuration.

#### Step 4: NixOS Installation

Install NixOS using the flake configuration:

```bash
sudo nixos-install --flake .#nauvoo
```

Set the root password when prompted, then reboot.

#### Step 5: Post-Installation Setup

After rebooting into the new system:

1. **Clone repository to /etc/nixos** (if not already there):
   ```bash
   cd /etc/nixos
   git clone git@github.com:Deatrin/dotfiles-redux.git .
   sudo chown -R deatrin:users .
   ```

2. **Setup opnix for user secrets**:
   ```bash
   # Authenticate with 1Password CLI
   eval $(op signin --account <your-account>.1password.com)

   # Note: System-level opnix not configured for nauvoo
   # User secrets provisioned automatically during home-manager activation
   ```

3. **Setup atuin** (shell history sync):
   ```bash
   atuin login --username $(op item get "atuin" --fields label=username) \
               --password $(op item get "atuin" --fields label=password) \
               --key "$(op item get "atuin" --fields label=key)"
   atuin import auto
   atuin sync -f
   ```

4. **Setup kubeconfig** (if needed):
   ```bash
   mkdir -p ~/.kube
   op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
   ```

#### Step 6: Verify Services

Check that all services are running:

```bash
# Docker
docker ps

# Plex (should be accessible at http://10.1.30.100:32400/web)
systemctl status plex

# Jellyseerr (should be accessible at http://10.1.30.100:5055)
systemctl status jellyseerr

# NFS mount
mount | grep nmedia
ls /mnt/nmedia

# Tailscale
tailscale status

# NVIDIA
nvidia-smi
```

#### Step 7: Configure Plex and Jellyseerr

1. **Plex**: Navigate to http://10.1.30.100:32400/web and complete setup, adding /mnt/nmedia libraries
2. **Jellyseerr**: Navigate to http://10.1.30.100:5055 and connect to Plex

### Troubleshooting

#### YubiKey Not Working

If YubiKey authentication fails:

```bash
gpg-connect-agent updatestartuptty /bye
```

#### NFS Mount Not Working

Check network connectivity to NFS server:

```bash
ping 10.1.10.5
showmount -e 10.1.10.5
```

Manually remount:

```bash
sudo mount -t nfs 10.1.10.5:/volume1/Roci/Media_Storage /mnt/nmedia
```

#### NVIDIA GPU Not Detected

Verify GPU passthrough in VM configuration, then check:

```bash
lspci | grep -i nvidia
nvidia-smi
```

If needed, rebuild:

```bash
sudo nixos-rebuild switch --flake .#nauvoo
```

#### Plex Hardware Transcoding Not Working

Ensure NVIDIA container toolkit is working:

```bash
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

## Updating Configuration

To update the configuration from GitHub and rebuild:

```bash
cd /etc/nixos
git pull
sudo nixos-rebuild switch --flake .#nauvoo
# or with nh
nh os switch
```

## Remote Installation (Advanced)

For remote installation via nixos-anywhere:

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#nauvoo root@<target-ip>
```

To generate hardware configuration remotely:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#nauvoo \
  --generate-hardware-config nixos-generate-config ./hosts/nixos/nauvoo/hardware-configuration.nix \
  root@<target-ip>
```

**Note**: Remote installation requires SSH access to the target machine booted from NixOS ISO.
