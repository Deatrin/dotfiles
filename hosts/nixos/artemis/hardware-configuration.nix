# PLACEHOLDER — replace with the output of `nixos-generate-config` run on the actual machine.
# After booting the NixOS installer and running disko, generate this with:
#   nixos-generate-config --show-hardware-config > hardware-configuration.nix
# Then commit the result before running nixos-install.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
