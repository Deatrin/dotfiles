{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.jellyseerr = {
    containerConfig = {
      image = "ghcr.io/fallenbagel/jellyseerr:latest";
      runInit = true;
      environments = {
        LOG_LEVEL = "debug";
        TZ = "America/Los_Angeles";
        PORT = "5055";
      };
      volumes = [
        "/var/lib/jellyseerr/config:/app/config:rw"
      ];
      networks = [
        networks.traefik-network.ref
      ];
      labels = {
        "homepage.group" = "Arr-Stack";
        "homepage.name" = "jellyseerr";
        "homepage.icon" = "jellyseerr.png";
        "homepage.href" = "https://seerr.jennex.dev";
        "homepage.description" = "media requests";
        "traefik.enable" = "true";
        "traefik.http.routers.jellyseerr.rule" = "Host(`seerr.jennex.dev`)";
        "traefik.http.routers.jellyseerr-secure.entrypoints" = "websecure";
        "traefik.http.routers.jellyseerr-secure.tls" = "true";
        "traefik.http.services.jellyseerr.loadbalancer.server.port" = "5055";
      };
      healthCmd = "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1";
      healthStartPeriod = "20s";
      healthTimeout = "3s";
      healthInterval = "15s";
      healthRetries = 3;
      autoUpdate = "registry";
    };
    serviceConfig = {
      Restart = "always";
      TimeoutStartSec = "60";
    };
  };

  # Ensure config directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyseerr 0755 root root -"
    "d /var/lib/jellyseerr/config 0755 root root -"
  ];
}
