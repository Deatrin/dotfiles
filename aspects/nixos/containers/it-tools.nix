{
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
          labels = [
            "homepage.group=Dev & Games"
            "homepage.name=IT Tools"
            "homepage.icon=it-tools.png"
            "homepage.href=https://it-tools.jennex.dev"
            "homepage.description=Helpful Tools"
            "traefik.enable=true"
            "traefik.http.routers.it_tools.rule=Host(`it-tools.jennex.dev`)"
            "traefik.http.routers.it_tools-secure.entrypoints=https"
            "traefik.http.routers.it_tools-secure.rule=Host(`it-tools.jennex.dev`)"
            "traefik.http.routers.it_tools-secure.tls=true"
            "traefik.http.services.it_tools.loadbalancer.server.port=80"
          ];
        };
      };
    };
  };
}
