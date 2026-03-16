# razerback

Dell Precision 5760 laptop running NixOS with Hyprland desktop environment.

## Hardware Specifications

- **Platform**: x86_64-linux
- **Model**: Dell Precision 5760
- **CPU**: Intel with Thunderbolt support (kvm-intel)
- **Storage**: Encrypted LUKS with disko partitioning
- **Special Hardware**:
  - Thunderbolt ports
  - RTSX PCI SD card reader

## Enabled Services & Features

### System Services

| Service | Description | Config Location |
|---------|-------------|-----------------|
| Docker | Container runtime | [hosts/common/optional/docker.nix](../../common/optional/docker.nix) |
| Hyprland | Wayland compositor | [home-manager/common/features/desktop](../../../home-manager/common/features/desktop/) |
| XWayland | X11 compatibility layer | [hosts/common/optional/xwayland.nix](../../common/optional/xwayland.nix) |
| Auto-upgrade | Automatic system updates | [hosts/common/nixos/auto-upgrade.nix](../../common/nixos/auto-upgrade.nix) |
| Tailscale | VPN for remote access | [hosts/common/nixos/tailscale.nix](../../common/nixos/tailscale.nix) |
| OpenSSH | Remote shell access | [hosts/common/nixos/openssh.nix](../../common/nixos/openssh.nix) |
| YubiKey Support | Hardware authentication | [hosts/common/nixos/default.nix](../../common/nixos/default.nix) |
| Bluetooth | Wireless connectivity | [hosts/common/nixos/default.nix](../../common/nixos/default.nix) |

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

### Secrets Management

No system-level opnix secrets configured currently.

User-level secrets via opnix:
- Shell environment variables (1Password servers vault)

## From Fresh Machine to Fully Configured

### Prerequisites

1. NixOS ISO installation media (USB stick recommended)
2. Encryption passphrase for disk encryption
3. 1Password account with service account token
4. YubiKey (optional but recommended)

### Installation Steps

#### Step 1: Boot from NixOS ISO

Boot the laptop from NixOS installation media (USB stick).

#### Step 2: Clone Repository

```bash
# Install git in live environment
nix-shell -p git

# Clone the repository
git clone https://github.com/Deatrin/dotfiles-redux.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

#### Step 3: Create Encryption Key

This machine uses LUKS encryption. Create the encryption key:

```bash
# Create a secure encryption passphrase
echo '<your-secure-passphrase>' > /tmp/secret.key
```

**Important**: Remember this passphrase! You'll need it to boot the machine.

#### Step 4: Disk Setup with Disko

Partition and encrypt the disk using the declarative disko configuration:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/nixos/razerback/disko-config.nix
```

This will:
- Partition the disk according to the configuration
- Set up LUKS encryption
- Create filesystems
- Mount everything ready for installation

#### Step 5: NixOS Installation

Install NixOS using the flake configuration:

```bash
sudo nixos-install --flake .#razerback
```

Set the root password when prompted, then reboot.

#### Step 6: Post-Installation Setup

After rebooting (you'll be prompted for the encryption passphrase):

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

5. **Setup YubiKey for sudo**:
   ```bash
   # Follow YubiKey setup instructions in troubleshooting section below
   ```

#### Step 7: Verify Desktop Environment

Log out and log back in to start Hyprland:

```bash
# Check Hyprland is running
echo $XDG_SESSION_TYPE  # Should show "wayland"
hyprctl version
```

Launch applications:
- Press `Super + D` for application launcher (Rofi)
- Press `Super + Return` for terminal (Ghostty)

### Troubleshooting

#### YubiKey Setup for sudo

To enable YubiKey authentication for sudo:

1. Insert YubiKey
2. Initialize U2F:
   ```bash
   pamu2fcfg > ~/.config/Yubico/u2f_keys
   ```
3. Test sudo with YubiKey - you'll be prompted to touch the key

If YubiKey authentication fails:
```bash
gpg-connect-agent updatestartuptty /bye
```

#### Thunderbolt Permissions

If Thunderbolt devices aren't working:

```bash
# Check Thunderbolt status
boltctl list

# Authorize device
boltctl authorize <device-id>
```

#### Hyprland Not Starting

Check Hyprland logs:

```bash
journalctl --user -u hyprland
cat ~/.local/share/hyprland/hyprland.log
```

Rebuild and try again:

```bash
sudo nixos-rebuild switch --flake .#razerback
```

#### Docker Permission Issues

Add user to docker group (already done in config, but if needed):

```bash
sudo usermod -aG docker deatrin
# Log out and back in
```

#### Wi-Fi Not Working

NetworkManager should handle Wi-Fi automatically. If not:

```bash
nmcli device wifi list
nmcli device wifi connect <SSID> password <password>
```

## Updating Configuration

To update the configuration from GitHub and rebuild:

```bash
cd /etc/nixos
git pull
sudo nixos-rebuild switch --flake .#razerback
# or with nh
nh os switch
```

## Remote Installation (Advanced)

For remote installation via nixos-anywhere:

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#razerback root@<target-ip>
```

To generate hardware configuration remotely:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#razerback \
  --generate-hardware-config nixos-generate-config ./hosts/nixos/razerback/hardware-configuration.nix \
  root@<target-ip>
```

**Note**: Remote installation requires SSH access to the target machine booted from NixOS ISO.
