# artemis

NixOS gaming PC — dual-boot with Windows.

## Hardware

| Component | Spec                        |
| --------- | --------------------------- |
| CPU       | AMD Ryzen 9 9950X3D         |
| RAM       | 64 GB                       |
| GPU       | NVIDIA RTX 5080 (Blackwell) |
| Storage   | 2TB NVMe                    |
| Platform  | x86_64-linux                |

## Storage Layout

Dual-boot: Windows + NixOS on a single 2TB NVMe.

| Partition | Size   | Filesystem   | Purpose                                     |
| --------- | ------ | ------------ | ------------------------------------------- |
| p1        | ~1GB   | vfat (EFI)   | Shared bootloader — created by Windows      |
| p2        | ~512GB | NTFS         | Windows OS + Rekordbox + Windows-only games |
| p3        | ~1.5TB | LUKS → BTRFS | NixOS                                       |

**BTRFS subvolumes** (zstd compression, noatime): `/`, `/nix`, `/home`

No LVM, no dedicated swap — using zramSwap instead.

## Services & Features

| Feature            | Config                                                                                 |
| ------------------ | -------------------------------------------------------------------------------------- |
| Hyprland           | [home-manager/common/features/desktop](../../../home-manager/common/features/desktop/) |
| greetd (tuigreet)  | [hosts/common/optional/greetd.nix](../../common/optional/greetd.nix)                   |
| Steam + Proton     | `programs.steam` in [default.nix](default.nix)                                         |
| NVIDIA RTX 5080    | `hardware.nvidia` in [default.nix](default.nix)                                        |
| Mullvad VPN        | `services.mullvad-vpn` in [default.nix](default.nix)                                   |
| Tailscale          | [hosts/common/nixos/tailscale.nix](../../common/nixos/tailscale.nix)                   |
| op-connect-secrets | [hosts/nixos/artemis/secrets.nix](secrets.nix)                                         |

### Monitors (3-display)

| Display | Resolution | Position               |
| ------- | ---------- | ---------------------- |
| Left    | 2560x1440  | Landscape              |
| Center  | 5120x2160  | Landscape (ultrawide)  |
| Right   | 1920x1080  | Portrait (rotated 90°) |

> Confirm actual `DP-X` connector names via `hyprctl monitors` after first boot
> and update `home-manager/nixos/deatrin_artemis.nix` if they differ from
> `DP-1/2/3`.

## Secrets

System-level (op-connect-secrets, remote client → nauvoo `10.1.30.100:8080`):

- `tailscaleKey` → `/run/opnix/tailscale-key`

User-level (opnix home-manager, `opnix_personal.nix`):

- Shell environment variables

Bootstrap token (manually placed, never managed by Nix):

- `/etc/op-connect-token` — nauvoo Connect server token (see Install step 6)

## Build (after install)

```bash
nh os switch
# or
sudo nixos-rebuild switch --flake .#artemis
```

---

## Install

> **Windows must be installed first.** The Windows installer overwrites
> bootloaders — NixOS first means Windows blows away systemd-boot.

### 1. Install Windows

Let Windows create the EFI partition and its own partition (~512GB). Leave the
remaining ~1.5TB unallocated.

### 2. Finish Windows setup

Boot Windows once — complete setup, activate, install Rekordbox + Pioneer
software. Get Windows to a known-good state before touching the partition table
again.

### 3. Boot NixOS ISO

Use the minimal or graphical NixOS ISO.

### 4. Clone dotfiles

```bash
nix-shell -p git
git clone https://github.com/Deatrin/dotfiles /mnt/dotfiles
cd /mnt/dotfiles
```

### 5. Inspect disk layout

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
```

Identify:

- The EFI partition (vfat, ~1GB) — typically `/dev/nvme0n1p1`
- The Windows partition (ntfs, ~512GB) — typically `/dev/nvme0n1p2`
- The unallocated space for NixOS

### 6. Create the NixOS partition

```bash
# Create a new partition in the unallocated space
# Adjust start offset to immediately after the Windows partition
parted /dev/nvme0n1 mkpart primary 515GiB 100%
```

Verify with `lsblk` — the new NixOS partition should appear as `/dev/nvme0n1p3`
(or similar).

### 7. Update disko-config.nix if needed

If the partition paths differ from `p1`/`p3`, update them in
`hosts/nixos/artemis/disko-config.nix` before continuing.

### 8. Generate hardware config

```bash
nixos-generate-config --show-hardware-config > hosts/nixos/artemis/hardware-configuration.nix
```

Review and commit.

### 9. Run disko (format only)

> **Use `--mode format`, NOT `--mode disko`.** `--mode disko` recreates the
> partition table and will wipe Windows. `--mode format` only formats the
> declared partitions.

```bash
# Create LUKS encryption key for install
echo -n "your-passphrase" > /tmp/secret.key

nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode format hosts/nixos/artemis/disko-config.nix
```

sudo install -m600 /dev/stdin /etc/op-connect-token

### 10. Install NixOS

```bash
sudo nixos-install --flake /mnt/dotfiles#artemis
```

### 11. Reboot

Remove the ISO. systemd-boot will present both Windows and NixOS at the boot
menu.

---

## First Boot

### 1. Clone dotfiles

```bash
sudo git clone https://github.com/Deatrin/dotfiles /etc/nixos
sudo chown -R deatrin:users /etc/nixos
cd /etc/nixos
```

### 2. Place op-connect token

nauvoo must be reachable at `10.1.30.100:8080` (home LAN — before Tailscale is
up, there's no other route).

```bash
sudo install -m600 /dev/stdin /etc/op-connect-token
# paste the Connect token, then Ctrl+D
```

### 3. Rebuild to provision secrets

```bash
nh os switch
```

This fetches the Tailscale auth key from 1Password Connect and autoconnects.
After this, nauvoo is reachable over Tailscale for future rebuilds.

### 4. Verify Tailscale

```bash
tailscale status
```

Confirm artemis appears in the Tailscale admin panel.

### 5. Add Flathub + install DaVinci Resolve

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.blackmagicdesign.DaVinciResolve
```

### 6. Authenticate rclone remotes

```bash
rclone config
# Follow OAuth browser flow for "dropbox" and "gdrive" remotes
# Name them "dropbox" and "gdrive" to match the systemd service definitions
```

The bisync timers will start automatically after this.

### 7. Confirm monitor layout

```bash
hyprctl monitors
```

Update `home-manager/nixos/deatrin_artemis.nix` with the correct `DP-X`
connector names if they differ from `DP-1/2/3`.

### 8. Post-install

```bash
# Atuin history sync
atuin login \
  --username $(op item get "atuin" --fields label=username) \
  --password $(op item get "atuin" --fields label=password) \
  --key "$(op item get "atuin" --fields label=key)"
atuin import auto
atuin sync -f
```

---

## Troubleshooting

### NVIDIA driver not loading

Check that the open kernel module is supported for your driver version:

```bash
sudo dmesg | grep nvidia
sudo journalctl -b | grep nvidia
```

If Blackwell isn't yet in the stable channel, switch to beta in `default.nix`:

```nix
hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
```

Or pull from unstable if needed.

### Secrets not provisioning

artemis uses `op-connect-secrets` pointing at nauvoo. `opnix-secrets.service` is
a compatibility shim that delegates to it.

```bash
sudo systemctl status op-connect-secrets.service
sudo journalctl -u op-connect-secrets.service -n 30 --no-pager
sudo ls -la /run/opnix/
```

Common causes:

- `/etc/op-connect-token` missing — see First Boot step 2
- nauvoo not reachable at `10.1.30.100:8080` — check network, must be on home
  LAN for initial setup

### Hyprland cursor glitches

Already configured with `cursor.no_hardware_cursors = true` in
`deatrin_artemis.nix`. If issues persist, also set:

```
env = LIBVA_DRIVER_NAME,nvidia
```

(already included in the NVIDIA env block)

### Windows missing from boot menu

systemd-boot auto-detects Windows via the EFI partition. If it doesn't appear:

```bash
bootctl list
```

If Windows isn't listed, check that the EFI partition is mounted and intact:

```bash
ls /boot/EFI/Microsoft/
```
