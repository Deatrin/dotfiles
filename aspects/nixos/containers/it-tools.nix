{self, ...}: {
  flake.modules.nixos.it-tools = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.it-tools;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.it-tools.enable = lib.mkEnableOption "IT Tools container";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.containers.it-tools = {
        containerConfig = {
          image = "docker.io/corentinth/it-tools:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          labels = self.lib.webLabels {
            host = "it-tools.jennex.dev";
            router = "it_tools";
            port = 80;
            homepage = {
              group = "Dev & Games";
              name = "IT Tools";
              icon = "it-tools.png";
              description = "Helpful Tools";
            };
          };
        };
      };
    };
  };
}
