# 1Password Connect Server — connect-api + connect-sync
#
# Provides a local 1Password Connect API at 127.0.0.1:8080 for secret
# fetching without hitting 1Password cloud API rate limits.
#
# Prerequisites (manually placed, never managed by Nix):
#   /etc/op-connect/1password-credentials.json  — from 1Password developer portal
#   /etc/op-connect-token                       — Connect access token
#
# The API is loopback-only and not exposed via Traefik.
{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /etc/op-connect 0700 root root -"
    "d /var/lib/op-connect 0777 root root -"
  ];

  virtualisation.quadlet = {
    networks.connect_network = {};

    containers.op-connect-api = {
      containerConfig = {
        image = "docker.io/1password/connect-api:latest";
        autoUpdate = "registry";
        networks = [networks.connect_network.ref];
        publishPorts = ["127.0.0.1:8080:8080"];
        volumes = [
          "/etc/op-connect/1password-credentials.json:/home/opuser/.op/1password-credentials.json:ro"
          "/var/lib/op-connect:/home/opuser/.op/data"
        ];
      };
    };

    containers.op-connect-sync = {
      unitConfig = {
        After = ["op-connect-api.service"];
        Requires = ["op-connect-api.service"];
      };
      containerConfig = {
        image = "docker.io/1password/connect-sync:latest";
        autoUpdate = "registry";
        networks = [networks.connect_network.ref];
        volumes = [
          "/etc/op-connect/1password-credentials.json:/home/opuser/.op/1password-credentials.json:ro"
          "/var/lib/op-connect:/home/opuser/.op/data"
        ];
      };
    };
  };
}
