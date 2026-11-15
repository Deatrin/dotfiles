# Whole-disk disko config for artemis: NixOS owns the entire 2TB NVMe.
# Windows lives on a separate 1TB drive with its own ESP (see "Booting Windows"
# below).
#
# WARNING: until the reinstall, do NOT rebuild artemis with this file. The
# running system lives on the old layout (shared Windows ESP on p1, LUKS on p5).
# This config mounts by-partlabel paths that don't exist yet, so a rebuild
# followed by a reboot would fail to unlock root.
#
# Install order:
#   1. Disconnect the 2TB drive (or disable it in BIOS) and install Windows on
#      the 1TB drive. With the 2TB disconnected, the Windows installer has to
#      put its own ESP on the 1TB drive.
#   2. Reconnect the 2TB drive and boot the NixOS ISO.
#   3. Confirm the target disk: ls -l /dev/disk/by-id/ | grep nvme
#      (the device path below must be the 990 PRO 2TB, NOT the 1TB)
#   4. echo -n '<luks passphrase>' > /tmp/secret.key
#   5. Clone the artemis-reinstall branch (GitHub mirror needs no keys; this
#      change lives there, not on main, until the reinstall is done):
#        git clone -b artemis-reinstall https://github.com/Deatrin/dotfiles /tmp/dotfiles
#   6. Wipe, partition, format and mount at /mnt:
#        sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- \
#          --mode destroy,format,mount /tmp/dotfiles/hosts/nixos/artemis/disko-config.nix
#   7. Copy the checkout onto the new disk (the ISO's /tmp is RAM, gone on reboot):
#        sudo mkdir -p /mnt/etc && sudo cp -a /tmp/dotfiles /mnt/etc/nixos
#        sudo chown -R 1000:100 /mnt/etc/nixos
#   8. sudo nixos-install --flake /mnt/etc/nixos#artemis
#   9. Place the op-connect token before first boot:
#        sudo install -m600 /dev/stdin /mnt/etc/op-connect-token
#  10. Reboot. Full guide: hosts/nixos/artemis/REINSTALL.md
#  11. After first boot: Secure Boot via lanzaboote (REINSTALL.md section 4).
#
# Layout:
#   ESP   2G     vfat  /boot   (NixOS only, no longer shared with Windows)
#   luks  rest   LUKS "cryptroot" -> BTRFS (/, /nix, /home)
#
# Booting Windows: use the motherboard boot menu (F12). systemd-boot only
# auto-detects Windows on its own ESP, and the efiDeviceHandle/EDK2-shell
# workaround doesn't work with lanzaboote + Secure Boot (REINSTALL.md section 5).
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
