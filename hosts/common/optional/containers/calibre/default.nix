{config, ...}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  virtualisation.quadlet = {
    volumes."calibre-data" = {};

    containers."calibre-web" = {
      containerConfig = {
        image = "lscr.io/linuxserver/calibre-web:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = {
          PUID = "1000";
          PGID = "1000";
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-calibre";
          OAUTHLIB_RELAX_TOKEN_SCOPE = "1";
        };
        volumes = [
          "${volumes."calibre-data".ref}:/config"
          "/storage/media/books:/books"
        ];
        labels = [
          "homepage.group=Self-Hosted"
          "homepage.name=Calibre"
          "homepage.icon=calibre.png"
          "homepage.href=https://calibre.deatrin.dev"
          "homepage.description=Books"
          "traefik.enable=true"
          "traefik.http.routers.calibre.rule=Host(`calibre.deatrin.dev`)"
          "traefik.http.routers.calibre-secure.entrypoints=https"
          "traefik.http.routers.calibre-secure.rule=Host(`calibre.deatrin.dev`)"
          "traefik.http.routers.calibre-secure.tls=true"
          "traefik.http.services.calibre.loadbalancer.server.port=8083"
        ];
      };
    };
  };
}
