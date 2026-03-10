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
        "homepage.href=https://it-tools.deatrin.dev"
        "homepage.description=Helpful Tools"
        "traefik.enable=true"
        # Public router (Let's Encrypt via Cloudflare)
        "traefik.http.routers.it_tools.rule=Host(`it-tools.deatrin.dev`)"
        "traefik.http.routers.it_tools-secure.entrypoints=https"
        "traefik.http.routers.it_tools-secure.rule=Host(`it-tools.deatrin.dev`)"
        "traefik.http.routers.it_tools-secure.tls=true"
        "traefik.http.routers.it_tools-secure.tls.certresolver=cloudflare"
        "traefik.http.services.it_tools.loadbalancer.server.port=80"
        # Tailscale router (Tailscale cert)
        "traefik.http.routers.it_tools-ts.entrypoints=https"
        "traefik.http.routers.it_tools-ts.rule=Host(`it-tools.tail64718.ts.net`)"
        "traefik.http.routers.it_tools-ts.tls=true"
        "traefik.http.routers.it_tools-ts.tls.certresolver=tailscale"
        "traefik.http.routers.it_tools-ts.service=it_tools"
      ];
    };
  };
}
