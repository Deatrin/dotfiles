{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.grocy = {
    containerConfig = {
      image = "lscr.io/linuxserver/grocy:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/Los_Angeles";
      };
      volumes = ["/home/deatrin/docker_volumes/grocy:/config"];
      labels = [
        "homepage.group=Self-Hosted"
        "homepage.name=grocy"
        "homepage.icon=grocy.png"
        "homepage.href=https://grocy.jennex.dev"
        "homepage.description=Inventory Management"
        "traefik.enable=true"
        "traefik.http.routers.grocy.rule=Host(`grocy.jennex.dev`)"
        "traefik.http.routers.grocy-secure.entrypoints=websecure"
        "traefik.http.routers.grocy-secure.tls=true"
        "traefik.http.services.grocy.loadbalancer.server.port=80"
      ];
    };
  };
}
