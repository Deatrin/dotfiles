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
    ../../common/optional/quadlet.nix
    ../../common/optional/containers
    ../../common/optional/reboot-required.nix
    ../../common/optional/vscode-server.nix
  ];

  services.pihole-quadlet.dnsListenIP = "10.1.40.200";
  services.forgejo-quadlet.sshPort = 2222; # nauvoo prod: set to 22 (system SSH is on 2222 there)
  networking = {
    hostName = "testbed";
    networkmanager.enable = true;
    interfaces.ens18.ipv4.addresses = [
      {
        address = "10.1.40.200";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.1.40.1";
    nameservers = ["10.1.30.1"];
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
