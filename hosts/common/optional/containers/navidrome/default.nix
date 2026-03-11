{config, ...}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  virtualisation.quadlet = {
    volumes.navidrome = {};

    containers.navidrome = {
      containerConfig = {
        image = "docker.io/deluan/navidrome:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        volumes = [
          "${volumes.navidrome.ref}:/data"
          "/storage/media/music:/music:ro"
        ];
        labels = [
          "homepage.group=Self-Hosted"
          "homepage.name=Navidrome"
          "homepage.icon=navidrome.png"
          "homepage.href=https://navi.jennex.dev"
          "homepage.description=Music Player"
          "traefik.enable=true"
          "traefik.http.routers.navi.rule=Host(`navi.jennex.dev`)"
          "traefik.http.routers.navi-secure.entrypoints=https"
          "traefik.http.routers.navi-secure.rule=Host(`navi.jennex.dev`)"
          "traefik.http.routers.navi-secure.tls=true"
          "traefik.http.services.navi.loadbalancer.server.port=4533"
        ];
      };
    };
  };
}
