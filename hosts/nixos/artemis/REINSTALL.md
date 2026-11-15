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
2. Install Windows 11 on the 1TB. **Leave the Secure Boot settings in the BIOS
   alone for now.** The firmware's keys are currently wiped (it's in Setup
   Mode), and Windows 11 installs fine like that. Secure Boot gets turned on
   in section 4, after NixOS is installed.
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
      jj log -r 'main@forgejo..artemis-reinstall'   # any "conflict" markers?
      jj bookmark set main -r artemis-reinstall
      jj git push --remote forgejo -b main
      jj git push --remote origin -b main
      jj bookmark delete artemis-reinstall
      jj git push --remote forgejo -b artemis-reinstall   # deletes the remote branch
      jj git push --remote origin -b artemis-reinstall
      jj new main
      ```
      **If the log shows a conflict:** it will be `flake.lock` in the
      "secure-boot" commit, because the nightly bumps moved main's lock while
      the branch added the `lanzaboote` input. Fix it before setting main
      (jj won't push a conflicted commit):
      ```sh
      jj edit <change id of the conflicted commit>
      jj restore --from main@forgejo flake.lock   # take main's lock
      nix flake lock                              # re-adds lanzaboote only
      jj new artemis-reinstall
      ```
      Then carry on from `jj bookmark set main`.

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

## 4. Secure Boot (lanzaboote)

Do this after section 3, once artemis boots normally from the new layout.

**Two sets of keys end up in the firmware:**

| Keys | Where they come from | What they sign |
|---|---|---|
| **Yours** (PK, KEK, db) | `sbctl create-keys`, stored in `/var/lib/sbctl` | systemd-boot and every NixOS generation (lanzaboote signs them on each rebuild) |
| **Microsoft's** (KEK + db certs) | built into `sbctl`, added by `--microsoft` | Windows Boot Manager, the RTX 5080's firmware (GOP option ROM), Windows' own dbx updates |

**Never enroll without `--microsoft`.** The GPU firmware runs before any OS. If
it can't be verified, you can end up with no display at POST at all.

The config side already exists: `aspects/nixos/secure-boot.nix`
(`dotfiles.secure-boot.enable`, lanzaboote v1.2.0 pinned in `flake.nix`).
artemis has it set to `false` because lanzaboote can't install until the keys
exist.

### 4a. Windows: check BitLocker first

Boot Windows (F12 boot menu, see section 5). In an **admin** terminal:

```powershell
manage-bde -status C:
```

- **Protection Off:** nothing to do.
- **Protection On:** save the recovery key (`manage-bde -protectors -get C:`, or
  https://aka.ms/myrecoverykey if it's tied to your Microsoft account), then
  pause BitLocker for the next few reboots so the key change doesn't trigger
  a recovery prompt:
  ```powershell
  manage-bde -protectors -disable C: -RebootCount 3
  ```
  It turns itself back on after 3 reboots.

### 4b. Create your keys

Back in NixOS:

```sh
sudo sbctl create-keys
sudo sbctl status
```

`Installed: ✓ sbctl is installed`. Setup Mode may say Enabled already, which
is fine.

### 4c. Switch to lanzaboote (Secure Boot still off)

In `hosts/nixos/artemis/default.nix`:

```nix
secure-boot.enable = true;
```

```sh
nh os switch
sudo sbctl verify
```

Expected output: everything under `/boot/EFI/` is `✓ signed` **except** the
`/boot/EFI/nixos/*-bzImage.efi` kernel files. That's normal: lanzaboote's
signed stub checks those itself.

**Reboot once now**, with Secure Boot still off, to confirm the lanzaboote
bootloader works (the boot menu looks the same). Then commit and push the
toggle like any other change.

### 4d. Put the firmware into Setup Mode (Gigabyte X870E AORUS ELITE WIFI7)

```sh
systemctl reboot --firmware-setup
```

In the BIOS (F2 for Advanced Mode if it opens in Easy Mode). Labels vary a
little between BIOS versions:

1. **Boot → CSM Support → Disabled.** Secure Boot options stay greyed out
   while CSM is on.
2. **Boot → Secure Boot:**
   1. **Secure Boot → Enabled**
   2. **Secure Boot Mode → Custom.** This unlocks Key Management.
   3. **Key Management → Factory Key Provision → Disabled.** If this stays on,
      the firmware re-installs its default keys on the next boot and overwrites
      yours.
   4. **Key Management → Restore Factory Keys → Yes.** Right now the firmware
      has *no* keys at all, including **dbx** (the list of known-bad bootloaders).
      Restoring the defaults first brings back a real dbx.
   5. **Key Management → Platform Key (PK) → Delete.** Delete **only the PK**.
      Do **not** use "Reset To Setup Mode" / "Delete all Secure Boot
      variables", which would wipe dbx again. With no PK, the firmware is in
      Setup Mode and the OS can write new keys.
3. **F10**, save and exit, and boot NixOS.

### 4e. Enroll both sets of keys

```sh
sudo sbctl status
# Setup Mode: ✗ Enabled   ← must be Enabled before you go on

ls -l /sys/firmware/efi/efivars/dbx-*
# must exist and be several KB. If it's missing or tiny, redo 4d step 2.4.

sudo sbctl enroll-keys --microsoft
```

Expected: `Enrolling keys to EFI variables... With vendor keys from
microsoft...✓ Enrolled keys to the EFI variables!`

If it refuses with a message about **immutable** efivars files, run
`sudo chattr -i /sys/firmware/efi/efivars/{PK,KEK,db}-*` and retry.

This writes your PK/KEK/db plus Microsoft's KEK and db certs. dbx is left as is.
Writing a PK takes the firmware out of Setup Mode.

### 4f. Reboot and verify

The firmware now enforces Secure Boot, because it was set to Enabled in 4d.

```sh
bootctl status | grep 'Secure Boot'
# Secure Boot: enabled (user)
sudo sbctl status
# Setup Mode: ✓ Disabled / Secure Boot: ✓ Enabled
```

Then boot **Windows** from the F12 menu and check `msinfo32` → *Secure Boot
State: On*. If you paused BitLocker in 4a, it turns back on by itself, or
right away with `manage-bde -protectors -enable C:`.

### Living with it

- **Rebuilds re-sign automatically.** Nothing to do day to day.
- **The keys exist only in `/var/lib/sbctl`.** If they're lost (wiped disk,
  another reinstall), you can't sign new generations. Fix: back to 4d (delete
  the PK), `sbctl create-keys`, then 4e. Backing up the folder (root-only,
  contains private keys) is optional.
- **BIOS updates on Gigabyte boards often reset Secure Boot to factory keys.**
  If NixOS stops booting after a BIOS flash with a "Secure Boot violation":
  turn Secure Boot off, boot NixOS, then redo 4d and 4e. The keys are still in
  `/var/lib/sbctl`, so skip `create-keys`.
- **Won't boot after 4f?** In the BIOS set Secure Boot → Disabled and NixOS
  boots unverified. To go back to plain systemd-boot entirely, set
  `secure-boot.enable = false` and rebuild.
- **No display at all after 4f** (option ROM rejected): clear CMOS (the
  board's Clear CMOS button or jumper). That restores factory keys and turns
  Secure Boot off.

---

## 5. Booting Windows

Use the **motherboard boot menu (F12 at POST)** and pick *Windows Boot
Manager* on the 1TB. If you'd rather Windows be the default, change the boot
order in the BIOS and pick NixOS from F12 instead.

systemd-boot only finds Windows automatically on its *own* EFI partition, and
Windows now has its own on the 1TB. The usual NixOS workaround
(`boot.loader.systemd-boot.windows.<name>.efiDeviceHandle`, which goes through
an EDK2 UEFI shell entry) **doesn't work here**: lanzaboote replaces the
systemd-boot module, so those options are ignored, and with Secure Boot on the
unsigned shell wouldn't be allowed to run anyway.

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
