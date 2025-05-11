{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
    ../common/nixos
    ../common/nixos/auto-upgrade.nix
    ../common/nixos/users/deatrin
    ../common/optional/docker.nix
    ../common/optional/reboot-required.nix
    ../common/optional/xwayland.nix
  ];

  networking = {
    hostName = "tycho";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
