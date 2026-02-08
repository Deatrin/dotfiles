{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.apple-silicon.nixosModules.apple-silicon-support
    ./disko-config.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../common/nixos
    ../../common/nixos/users/deatrin
    ../../common/optional/font.nix
    ../../common/optional/xwayland.nix
    ../../common/optional/greetd.nix
  ];

  networking = {
    hostName = "chetzemoka";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # Better WPA3 support on Broadcom
    };
  };

  # May fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Apple keyboard layout fix
  boot.extraModprobeConfig = "options hid_apple iso_layout=0";

  # Required for Apple Silicon - cannot modify EFI variables
  boot.loader.efi.canTouchEfiVariables = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
