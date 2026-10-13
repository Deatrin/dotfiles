# Template for a new NixOS host (see README.md). After copying:
#   - rename networking.hostName (it also picks home-manager/nixos/deatrin_<hostName>.nix)
#   - set disko-config.nix's disk device and regenerate hardware-configuration.nix
#   - turn on the features the host needs under `dotfiles`
{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../common/nixos
    ../../common/nixos/users/deatrin
  ];

  # Opt-in features: one aspects/nixos/<name>.nix each. Examples:
  #   podman.enable = true;
  #   docker.enable = true;
  #   attic-client.enable = true;   # also needs atticToken in secrets.nix
  #   nfs.enable = true;
  dotfiles = {
    reboot-required.enable = true;
  };

  networking = {
    hostName = "vmtemplate"; # CHANGE ME
    networkmanager.enable = true;
    # DHCP by default. For a static address instead:
    # interfaces.ens18.ipv4.addresses = [
    #   {
    #     address = "10.1.30.X";
    #     prefixLength = 24;
    #   }
    # ];
    # defaultGateway = "10.1.30.1";
    # nameservers = ["10.1.30.1"];
  };

  # Rebuilds can hang waiting on these on VMs; nothing here needs them.
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Set to the NixOS release this host is first installed with, then never
  # change it. https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
