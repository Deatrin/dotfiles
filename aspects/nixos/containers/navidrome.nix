{self, ...}: {
  flake.modules.nixos.navidrome = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.navidrome;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.navidrome.enable = lib.mkEnableOption "Navidrome music server";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet = {
        volumes.navidrome = {};

        containers.navidrome = {
          containerConfig = {
            image = "docker.io/deluan/navidrome:latest";
            autoUpdate = "registry";
            networks = [networks.traefik_network.ref];
            volumes = [
              "${volumes.navidrome.ref}:/data"
              "/storage/media/music:/music:ro"
            ];
            labels = self.lib.webLabels {
              host = "navi.jennex.dev";
              router = "navi";
              port = 4533;
              homepage = {
                group = "Media";
                name = "Navidrome";
                icon = "navidrome.png";
                description = "Music Player";
              };
            };
          };
        };
      };
    };
  };
}
