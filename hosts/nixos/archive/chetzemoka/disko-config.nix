# Disko config for Asahi Linux on M2 MacBook Air
#
# IMPORTANT: Update the device path after Asahi installer runs.
# Run `lsblk` to find the correct NVMe partition that Asahi allocated.
# The Asahi installer carves partitions from the Apple APFS container,
# so the device will typically be something like /dev/nvme0n1p4 or similar.
#
# The EFI partition is shared with Asahi firmware and should already exist
# after the Asahi install - do NOT reformat it.
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # TODO: Update this to the actual device path from `lsblk`
        # This should be the partition Asahi allocated for NixOS
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
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
                  "/swap" = {
                    mountpoint = "/swap";
                    mountOptions = ["noatime"];
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
