{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.audiobookshelf = {
    containerConfig = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      publishPorts = ["13378:80"];
      environments = {
        TZ = "America/Los_Angeles";
      };
      volumes = [
        "/storage/media/audiobooks:/audiobooks"
        "/storage/media/audiobooks:/podcasts"
        "/home/deatrin/docker_volumes/audiobookshelf/config:/config"
        "/home/deatrin/docker_volumes/audiobookshelf/metadata:/metadata"
      ];
      labels = [
        "homepage.group=Self-Hosted"
        "homepage.name=Audiobookshelf"
        "homepage.icon=audiobookshelf.png"
        "homepage.href=https://audiobookshelf.jennex.dev"
        "homepage.description=Audiobook player"
        "traefik.enable=true"
        "traefik.http.routers.audiobookshelf.rule=Host(`audiobookshelf.jennex.dev`)"
        "traefik.http.routers.audiobookshelf-secure.entrypoints=websecure"
        "traefik.http.routers.audiobookshelf-secure.tls=true"
        "traefik.http.services.audiobookshelf.loadbalancer.server.port=80"
      ];
    };
  };
}
