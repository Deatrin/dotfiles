{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.hyprsettings.nixosModules.default
    ./disko-config.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../common/nixos
    ../../common/nixos/users/deatrin
    ../../common/optional/font.nix
    #    ../../common/optional/docker.nix
    ../../common/optional/podman.nix
    ../../common/optional/reboot-required.nix
    ../../common/optional/xwayland.nix
    ../../common/optional/greetd.nix
  ];

  networking = {
    hostName = "tycho";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  programs.hyprsettings.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
