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
  ];

  dotfiles = {
    font.enable = true;
    podman.enable = true;
    reboot-required.enable = true;
    xwayland.enable = true;
    greetd.enable = true;
    moonlight-qt.enable = true;
    attic-client.enable = true;
  };

  networking = {
    hostName = "tycho";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  programs.hyprsettings.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["deatrin"];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
