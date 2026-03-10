{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/homebox 0755 root root -"
  ];

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
      volumes = ["/var/lib/homebox:/data"];
      labels = [
        "homepage.group=Self-Hosted"
        "homepage.name=homebox"
        "homepage.icon=homebox.png"
        "homepage.href=https://homebox.deatrin.dev"
        "homepage.description=Home Inventory"
        "traefik.enable=true"
        "traefik.http.routers.homebox.rule=Host(`homebox.deatrin.dev`)"
        "traefik.http.routers.homebox-secure.entrypoints=https"
        "traefik.http.routers.homebox-secure.rule=Host(`homebox.deatrin.dev`)"
        "traefik.http.routers.homebox-secure.tls=true"
        "traefik.http.routers.homebox-secure.tls.certresolver=cloudflare"
        "traefik.http.services.homebox.loadbalancer.server.port=7745"
      ];
    };
  };
}
