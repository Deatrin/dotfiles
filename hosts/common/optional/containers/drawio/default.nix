{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.drawio = {
    containerConfig = {
      image = "docker.io/jgraph/drawio:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      labels = [
        "homepage.group=Dev & Games"
        "homepage.name=draw.io"
        "homepage.icon=si-diagramsdotnet"
        "homepage.href=https://drawio.jennex.dev"
        "homepage.description=Diagramming and whiteboarding"
        "traefik.enable=true"
        "traefik.http.routers.drawio.rule=Host(`drawio.jennex.dev`)"
        "traefik.http.routers.drawio-secure.entrypoints=https"
        "traefik.http.routers.drawio-secure.rule=Host(`drawio.jennex.dev`)"
        "traefik.http.routers.drawio-secure.tls=true"
        "traefik.http.services.drawio.loadbalancer.server.port=8080"
      ];
    };
  };
}
