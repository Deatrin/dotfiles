# KubeKosh — self-hosted K3s-in-a-container learning sandbox with browser terminal
# https://github.com/zeborg/kubekosh
#
# Runs a real K3s cluster inside the container, so it needs --privileged.
# No secrets required — progress is stored in a SQLite DB under /data.
{
  flake.modules.nixos.kubekosh = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.kubekosh;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.kubekosh.enable = lib.mkEnableOption "KubeKosh Kubernetes learning sandbox";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/kubekosh 0755 root root -"
      ];

      virtualisation.quadlet.containers.kubekosh = {
        containerConfig = {
          image = "docker.io/zeborg/kubekosh:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          podmanArgs = ["--privileged"];
          volumes = ["/var/lib/kubekosh:/data"];
          labels = [
            "homepage.group=Dev"
            "homepage.name=KubeKosh"
            "homepage.icon=kubernetes.png"
            "homepage.href=https://kubekosh.jennex.dev"
            "homepage.description=K3s Kubernetes learning sandbox"
            "traefik.enable=true"
            "traefik.http.routers.kubekosh.rule=Host(`kubekosh.jennex.dev`)"
            "traefik.http.routers.kubekosh-secure.entrypoints=https"
            "traefik.http.routers.kubekosh-secure.rule=Host(`kubekosh.jennex.dev`)"
            "traefik.http.routers.kubekosh-secure.tls=true"
            "traefik.http.services.kubekosh.loadbalancer.server.port=80"
          ];
        };
      };
    };
  };
}
