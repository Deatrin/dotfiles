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
    ../common/optional/qemu.nix
    ../common/optional/reboot-required.nix
    ../common/optional/vscode-server.nix
  ];

  networking = {
    hostName = "nauvoo";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    interfaces.ens18.ipv4.addresses = [
      {
        address = "10.1.30.10";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.1.30.1";
    nameservers = ["10.1.10.220"];
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
