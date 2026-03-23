{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/mealie 0755 root root -"
  ];

  virtualisation.quadlet.containers.mealie = {
    unitConfig = {
      After = ["opnix-secrets.service"];
      Requires = ["opnix-secrets.service"];
    };
    containerConfig = {
      image = "ghcr.io/mealie-recipes/mealie:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        TZ = "America/Los_Angeles";
        BASE_URL = "https://mealie.jennex.dev";
        ALLOW_SIGNUP = "false";
      };
      environmentFiles = ["/run/opnix/mealie-env"];
      volumes = ["/var/lib/mealie:/app/data"];
      labels = [
        "homepage.group=Home"
        "homepage.name=Mealie"
        "homepage.icon=mealie.png"
        "homepage.href=https://mealie.jennex.dev"
        "homepage.description=Recipe Manager"
        "traefik.enable=true"
        "traefik.http.routers.mealie.rule=Host(`mealie.jennex.dev`)"
        "traefik.http.routers.mealie-secure.entrypoints=https"
        "traefik.http.routers.mealie-secure.rule=Host(`mealie.jennex.dev`)"
        "traefik.http.routers.mealie-secure.tls=true"
        "traefik.http.services.mealie.loadbalancer.server.port=9000"
      ];
    };
  };
}
