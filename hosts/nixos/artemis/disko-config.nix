# Dual-boot disko config for artemis (Windows + NixOS on a single 2TB NVMe).
#
# Install order:
#   1. Install Windows — creates EFI (p1) + Windows partition (p2), leaving ~1.5TB unallocated
#   2. Boot Windows once to finish setup + install Rekordbox
#   3. Boot NixOS ISO
#   4. Manually create the NixOS partition in the unallocated space:
#        parted /dev/nvme0n1 mkpart primary 515GiB 100%
#        (adjust start offset to be just after the Windows partition)
#   5. Confirm exact device paths with: lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
#   6. Update device paths below if needed, then run disko:
#        nix run github:nix-community/disko -- --mode format /path/to/disko-config.nix
#        (--mode format formats only — does NOT recreate the partition table)
#   7. nixos-install --flake .#artemis
#
# Expected partition layout:
#   /dev/nvme0n1p1 — EFI     (~1GB, vfat, created by Windows — DO NOT FORMAT)
#   /dev/nvme0n1p2 — Windows (~512GB, ntfs, managed by Windows — DO NOT TOUCH)
#   /dev/nvme0n1p3 — NixOS   (~1.5TB, LUKS → BTRFS)
#
# NOTE: noFormat = true on the EFI filesystem prevents disko from wiping Windows
# boot files. The Windows partition (p2) is not declared here — disko ignores it.
{
  disko.devices = {
    disk = {
      # Reference the NixOS partition directly (not the whole disk).
      # Disko treats it as a raw block device and puts LUKS directly on it.
      # Adjust if the partition number differs after manual partitioning.
      nixos = {
        type = "disk";
        device = "/dev/nvme0n1p5";
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

  # Mount the existing Windows EFI partition — created by Windows installer.
  # Using fileSystems directly (not via disko) so disko never touches this partition.
  # Adjust device path if the EFI partition number differs.
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    options = ["umask=0077"];
  };
}
