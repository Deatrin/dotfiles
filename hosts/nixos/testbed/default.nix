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

  # Enable IP forwarding for Tailscale exit node
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
