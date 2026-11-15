# artemis reinstall: Windows → 1TB, NixOS → whole 2TB

Written 2026-11-15. Self-contained. The full disko config is in the appendix in
case the repo copy is missing or wrong.

## Target layout

| Drive | Contents |
|---|---|
| **1TB (new)** | Windows 11, its own EFI partition, created by the Windows installer |
| **Samsung 990 PRO 2TB** (`nvme-Samsung_SSD_990_PRO_2TB_S7KHNU0Y517514Z`) | NixOS: 2G EFI partition (`/boot`) + LUKS `cryptroot` → BTRFS (`/`, `/nix`, `/home`) |

This also gets rid of the old 196M Windows-shared EFI partition, which was 98%
full and caused the kernel truncation and FAT corruption problems.

---

## 0. Before you wipe (on the running system)

- [ ] **Do not `nh os switch` artemis with the new disko config before the
      reinstall.** It mounts `disk-main-ESP` / `disk-main-luks` partlabels that
      don't exist on the current disk, so the next reboot can't unlock root.
- [ ] **The `artemis-reinstall` branch must be on GitHub (`origin`).** This change
      lives on that branch, *not* main, so nothing builds it early. The ISO clones
      it from the public mirror. Check from any machine:
      `git ls-remote https://github.com/Deatrin/dotfiles artemis-reinstall`
      (it should print a commit hash). If the branch is missing, use the appendix
      copy of the disko config.
- [ ] Optional, to keep the same Syncthing device ID: copy
      `~/.config/syncthing/cert.pem` and `key.pem` off the machine.
      Skip this and you just re-pair artemis with nauvoo and tynan afterwards.
- [ ] Have the **op-connect token** reachable from another device (1Password).
- [ ] Have the **LUKS passphrase** you want to use decided.
- [ ] A NixOS ISO USB stick and a Windows 11 USB stick.
- [ ] Copy this file somewhere that isn't artemis.

---

## 1. Install Windows on the 1TB

1. **Unplug the 2TB drive** (or disable its M.2 slot in BIOS). This is the
   important part: with only the 1TB visible, the Windows installer has to
   create its own EFI partition there and can't touch the NixOS disk.
2. Install Windows 11 on the 1TB.
3. Finish setup (drivers, Rekordbox, etc.) whenever you like. That can happen
   later too.
4. Shut down and **reconnect the 2TB drive**.

---

## 2. Install NixOS on the 2TB

Boot the NixOS ISO. Get network up (wired is easiest; for Wi-Fi use `nmtui`).

```sh
sudo -i
```

### 2a. Confirm the target disk

```sh
ls -l /dev/disk/by-id/ | grep nvme
lsblk -o NAME,SIZE,MODEL
```

`nvme-Samsung_SSD_990_PRO_2TB_S7KHNU0Y517514Z` must be the **2TB**, not the 1TB.
If the serial differs, edit `device =` in the disko config before step 2d.

### 2b. LUKS passphrase file (only used during formatting)

```sh
echo -n 'YOUR-LUKS-PASSPHRASE' > /tmp/secret.key
```

### 2c. Get the config

```sh
git clone -b artemis-reinstall https://github.com/Deatrin/dotfiles /tmp/dotfiles
head -1 /tmp/dotfiles/hosts/nixos/artemis/disko-config.nix   # must say "Whole-disk"
```

### 2d. Wipe, partition, format and mount at `/mnt`

**This destroys everything on the 2TB.**

```sh
nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- \
  --mode destroy,format,mount /tmp/dotfiles/hosts/nixos/artemis/disko-config.nix
```

Check:

```sh
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
# expect: ~2G vfat at /mnt/boot, crypt → btrfs at /mnt, /mnt/nix, /mnt/home
```

### 2e. Put the repo in its permanent home

The ISO's `/tmp` is in RAM and disappears on reboot, so copy the checkout onto
the new disk now:

```sh
mkdir -p /mnt/etc
cp -a /tmp/dotfiles /mnt/etc/nixos
chown -R 1000:100 /mnt/etc/nixos      # deatrin:users
```

### 2f. Install

```sh
nixos-install --flake /mnt/etc/nixos#artemis
```

Set the root password when prompted. deatrin gets the `initialHashedPassword`
from the config.

### 2g. op-connect token (secrets won't work without it)

Paste the token, press Enter, then Ctrl+D:

```sh
install -m600 /dev/stdin /mnt/etc/op-connect-token
```

### 2h. Reboot

```sh
umount -R /mnt
reboot
```

Pull the USB stick. systemd-boot on the 2TB should come up and ask for the
LUKS passphrase.

---

## 3. After first boot

- [ ] Secrets came through:
      `systemctl status op-connect-secrets` / `journalctl -u op-connect-secrets -p err`
- [ ] Repo remotes: `/etc/nixos` was cloned from GitHub over HTTPS. Re-add Forgejo
      and switch origin to SSH, then set up jj:
      ```sh
      cd /etc/nixos
      git remote set-url origin git@github.com:Deatrin/dotfiles.git
      git remote add forgejo ssh://git@forgejo.jennex.dev/deatrin/dotfiles.git
      jj git init --colocate
      jj git fetch --remote forgejo
      ```
- [ ] **Land the branch on main.** Now that artemis runs on the new layout, the
      disko change is safe on main:
      ```sh
      jj rebase -b artemis-reinstall -d main@forgejo
      jj bookmark set main -r artemis-reinstall
      jj git push --remote forgejo -b main
      jj git push --remote origin -b main
      jj bookmark delete artemis-reinstall
      jj git push --remote forgejo -b artemis-reinstall   # deletes the remote branch
      jj git push --remote origin -b artemis-reinstall
      jj new main
      ```
      Until then, the cloned checkout sits on the branch, so rebuilds keep the
      new layout. Don't check out the old main on artemis before this step: it
      still has the dual-boot disko config.
- [ ] **Tailscale:** delete the *old* artemis node in the admin console, so the new
      one gets the name `artemis` and not `artemis-1`.
- [ ] **SSH host key changed:** on other machines,
      `ssh-keygen -R artemis` (and the IP / Tailscale name, if you use those).
- [ ] **Syncthing:** either restore `cert.pem`/`key.pem` into
      `~/.config/syncthing/` and restart syncthing, or re-pair with nauvoo and
      tynan in the GUI (`claude-memory-dotfiles` folder).
- [ ] **rclone:** the dropbox and gdrive `rclone config` is still a TODO. The bisync
      timers fail until that's done.
- [ ] Steam / games: re-download.

---

## 4. Add Windows to the systemd-boot menu

systemd-boot only finds Windows automatically when it's on the *same* EFI
partition. Windows is now on the 1TB's EFI partition, so it needs an EDK2-shell
entry. **Until this is done, use the motherboard boot menu (F8/F11/F12) to
start Windows.**

### 4a. Enable the UEFI shell, rebuild, and find the handle

In `hosts/nixos/artemis/default.nix`:

```nix
boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
```

Rebuild, reboot, and pick the **EFI Shell** entry in the systemd-boot menu. Then:

```
map -c
```

Find the entry for the 1TB drive's EFI partition. To confirm it's the
Windows one:

```
ls HD1b:\EFI\Microsoft\Boot\
```

(replace `HD1b` with the candidate). `Bootmgfw.efi` should be there. Note
the handle and type `reset` to reboot.

### 4b. Add the entry

```nix
boot.loader.systemd-boot = {
  edk2-uefi-shell.enable = true;
  windows."11" = {
    title = "Windows 11";
    efiDeviceHandle = "HD1b";   # ← the handle you found
  };
};
```

Rebuild. "Windows 11" now shows in the boot menu.

**Gotcha:** plugging in USB drives can sometimes renumber handles. If the
Windows entry stops working, redo `map -c`, or use the motherboard boot menu.

---

## Appendix: whole-disk `disko-config.nix`

Save as `/tmp/disko-config.nix` on the ISO and point disko at it if the repo
copy isn't right. Before `nixos-install`, also copy it over
`/mnt/etc/nixos/hosts/nixos/artemis/disko-config.nix`. The installed system's
`fileSystems` / LUKS settings come from this file.

```nix
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7KHNU0Y517514Z";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
```
