{self, ...}: {
  flake.modules.nixos.drawio = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.drawio;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.drawio.enable = lib.mkEnableOption "draw.io container";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.containers.drawio = {
        containerConfig = {
          image = "docker.io/jgraph/drawio:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          labels = self.lib.webLabels {
            host = "drawio.jennex.dev";
            router = "drawio";
            port = 8080;
            homepage = {
              group = "Dev & Games";
              name = "draw.io";
              icon = "si-diagramsdotnet";
              description = "Diagramming and whiteboarding";
            };
          };
        };
      };
    };
  };
}
