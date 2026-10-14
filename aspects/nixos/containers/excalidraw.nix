{self, ...}: {
  flake.modules.nixos.excalidraw = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.excalidraw;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.excalidraw.enable = lib.mkEnableOption "Excalidraw container";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.containers.excalidraw = {
        containerConfig = {
          image = "docker.io/excalidraw/excalidraw:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          labels = self.lib.webLabels {
            host = "excalidraw.jennex.dev";
            router = "excalidraw";
            port = 80;
            homepage = {
              group = "Dev & Games";
              name = "Excalidraw";
              icon = "si-excalidraw";
              description = "Virtual whiteboard for sketching";
            };
          };
        };
      };
    };
  };
}
