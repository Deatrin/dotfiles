{self, ...}: {
  flake.modules.nixos.kavita = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.kavita;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.kavita.enable = lib.mkEnableOption "Kavita container";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/kavita 0755 root root -"
      ];

      virtualisation.quadlet.containers.kavita = {
        containerConfig = {
          image = "docker.io/jvmilazz0/kavita:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          volumes = [
            "/var/lib/kavita:/kavita/config"
            "/storage/media/books:/books:ro"
            "/storage/media/manga:/manga:ro"
          ];
          labels = self.lib.webLabels {
            host = "kavita.jennex.dev";
            router = "kavita";
            port = 5000;
            homepage = {
              group = "Media";
              name = "Kavita";
              icon = "kavita.png";
              description = "Manga, Comics & Books";
            };
          };
        };
      };
    };
  };
}
