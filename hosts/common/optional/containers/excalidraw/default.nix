{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.excalidraw = {
    containerConfig = {
      image = "docker.io/excalidraw/excalidraw:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      labels = [
        "homepage.group=Dev & Games"
        "homepage.name=Excalidraw"
        "homepage.icon=si-excalidraw"
        "homepage.href=https://excalidraw.jennex.dev"
        "homepage.description=Virtual whiteboard for sketching"
        "traefik.enable=true"
        "traefik.http.routers.excalidraw.rule=Host(`excalidraw.jennex.dev`)"
        "traefik.http.routers.excalidraw-secure.entrypoints=https"
        "traefik.http.routers.excalidraw-secure.rule=Host(`excalidraw.jennex.dev`)"
        "traefik.http.routers.excalidraw-secure.tls=true"
        "traefik.http.services.excalidraw.loadbalancer.server.port=80"
      ];
    };
  };
}
