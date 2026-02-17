{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.traefik = {
    containerConfig = {
      image = "docker.io/library/traefik:latest";
      publishPorts = [
        "80:80"
        "443:443"
      ];
      volumes = [
        "/var/lib/traefik/acme.json:/acme.json:rw"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      networks = [
        networks.traefik-network.ref
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.dashboard.rule" = "Host(`traefik.jennex.dev`)";
        "traefik.http.routers.dashboard.entrypoints" = "websecure";
        "traefik.http.routers.dashboard.tls" = "true";
        "traefik.http.routers.dashboard.service" = "api@internal";
      };
      environments = {
        TZ = "America/Los_Angeles";
      };
      # Traefik CLI arguments passed via exec
      exec = [
        "--api.dashboard=true"
        "--entrypoints.web.address=:80"
        "--entrypoints.websecure.address=:443"
        "--entrypoints.web.http.redirections.entrypoint.to=websecure"
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
        "--providers.docker.network=systemd-traefik-network"
        "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
        "--certificatesresolvers.letsencrypt.acme.storage=/acme.json"
      ];
      autoUpdate = "registry";
    };
    serviceConfig = {
      Restart = "always";
      TimeoutStartSec = "90";
    };
  };

  # Ensure acme storage file exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/traefik 0750 root root -"
    "f /var/lib/traefik/acme.json 0600 root root -"
  ];
}
