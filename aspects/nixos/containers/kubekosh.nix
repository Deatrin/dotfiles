# KubeKosh — self-hosted K3s-in-a-container learning sandbox with browser terminal
# https://github.com/zeborg/kubekosh
#
# Runs a real K3s cluster inside the container, so it needs --privileged.
# No secrets required — progress is stored in a SQLite DB under /data.
{self, ...}: {
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
          labels = self.lib.webLabels {
            host = "kubekosh.jennex.dev";
            router = "kubekosh";
            port = 80;
            homepage = {
              group = "Dev";
              name = "KubeKosh";
              icon = "kubernetes.png";
              description = "K3s Kubernetes learning sandbox";
            };
          };
        };
      };
    };
  };
}
