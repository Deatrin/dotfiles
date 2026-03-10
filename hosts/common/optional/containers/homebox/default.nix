{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  virtualisation.quadlet.containers.homebox = {
    containerConfig = {
      image = "ghcr.io/sysadminsmedia/homebox:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        HBOX_LOG_LEVEL = "info";
        HBOX_LOG_FORMAT = "text";
        HBOX_WEB_MAX_UPLOAD_SIZE = "10";
        HBOX_OPTIONS_ALLOW_ANALYTICS = "false";
      };
      volumes = ["/home/deatrin/docker_volumes/homebox:/data"];
      labels = [
        "homepage.group=Self-Hosted"
        "homepage.name=homebox"
        "homepage.icon=homebox.png"
        "homepage.href=https://homebox.jennex.dev"
        "homepage.description=Home Inventory"
        "traefik.enable=true"
        "traefik.http.routers.homebox.rule=Host(`homebox.jennex.dev`)"
        "traefik.http.routers.homebox-secure.entrypoints=websecure"
        "traefik.http.routers.homebox-secure.tls=true"
        "traefik.http.services.homebox.loadbalancer.server.port=7745"
      ];
    };
  };
}
