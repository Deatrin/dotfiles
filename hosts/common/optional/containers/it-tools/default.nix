{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.it-tools = {
    containerConfig = {
      image = "docker.io/corentinth/it-tools:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      publishPorts = ["8090:80"];
      labels = [
        "homepage.group=Dev"
        "homepage.name=IT Tools"
        "homepage.icon=it-tools.png"
        "homepage.href=https://it-tools.jennex.dev"
        "homepage.description=Helpful Tools"
        "traefik.enable=true"
        "traefik.http.routers.it_tools.rule=Host(`it-tools.jennex.dev`)"
        "traefik.http.routers.it_tools-secure.entrypoints=websecure"
        "traefik.http.routers.it_tools-secure.tls=true"
        "traefik.http.services.it_tools.loadbalancer.server.port=80"
      ];
    };
  };
}
