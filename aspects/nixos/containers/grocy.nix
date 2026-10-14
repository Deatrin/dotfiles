{self, ...}: {
  flake.modules.nixos.grocy = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.grocy;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.grocy.enable = lib.mkEnableOption "Grocy inventory management";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/grocy 0755 root root -"
      ];

      virtualisation.quadlet.containers.grocy = {
        containerConfig = {
          image = "lscr.io/linuxserver/grocy:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          environments = {
            PUID = "1000";
            PGID = "1000";
            TZ = "America/Los_Angeles";
          };
          volumes = ["/var/lib/grocy:/config"];
          labels = self.lib.webLabels {
            host = "grocy.jennex.dev";
            router = "grocy";
            port = 80;
            homepage = {
              group = "Home";
              name = "grocy";
              icon = "grocy.png";
              description = "Inventory Management";
            };
          };
        };
      };
    };
  };
}
