# Seerr — media request management (formerly Jellyseerr)
#
# No secrets required — all configuration stored in volume.
{config, ...}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/seerr 0755 root root -"
  ];

  virtualisation.quadlet = {
    volumes.seerr-config = {};

    containers.seerr = {
      containerConfig = {
        image = "ghcr.io/seerr-team/seerr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = {
          LOG_LEVEL = "debug";
          TZ = "America/Los_Angeles";
          PORT = "5055";
        };
        volumes = ["${volumes.seerr-config.ref}:/app/config"];
        labels = [
          "homepage.group=Arr-Stack"
          "homepage.name=Seerr"
          "homepage.icon=jellyseerr.png"
          "homepage.href=https://seerr.deatrin.dev"
          "homepage.description=Media Requests"
          "traefik.enable=true"
          "traefik.http.routers.seerr.rule=Host(`seerr.deatrin.dev`)"
          "traefik.http.routers.seerr-secure.entrypoints=https"
          "traefik.http.routers.seerr-secure.rule=Host(`seerr.deatrin.dev`)"
          "traefik.http.routers.seerr-secure.tls=true"
          "traefik.http.services.seerr.loadbalancer.server.port=5055"
        ];
      };
    };
  };
}
