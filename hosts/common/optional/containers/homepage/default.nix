# Homepage config lives at /home/deatrin/docker_volumes/homepage/config
# Uses the Podman socket instead of docker.sock
{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.homepage = {
    containerConfig = {
      image = "ghcr.io/gethomepage/homepage:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        HOMEPAGE_ALLOWED_HOSTS = "homepage.jennex.dev";
      };
      volumes = [
        "/home/deatrin/docker_volumes/homepage/config:/app/config"
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.homepage.rule=Host(`homepage.jennex.dev`)"
        "traefik.http.routers.homepage-secure.entrypoints=websecure"
        "traefik.http.routers.homepage-secure.tls=true"
        "traefik.http.services.homepage.loadbalancer.server.port=3000"
      ];
    };
  };
}
