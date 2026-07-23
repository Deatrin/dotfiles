{
  flake.modules.nixos.navidrome = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.navidrome;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.navidrome.enable = lib.mkEnableOption "Navidrome music server";

    config = lib.mkIf cfg.enable {
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
              "homepage.group=Media"
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
    };
  };
}
