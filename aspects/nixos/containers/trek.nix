{self, ...}: {
  flake.modules.nixos.trek = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.trek;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.trek.enable = lib.mkEnableOption "TREK travel planner";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/trek 0755 root root -"
        "d /var/lib/trek/data 0755 root root -"
        "d /var/lib/trek/uploads 0755 root root -"
      ];

      virtualisation.quadlet.containers.trek = {
        unitConfig = {
          After = ["opnix-secrets.service"];
          Requires = ["opnix-secrets.service"];
        };
        containerConfig = {
          image = "docker.io/mauriceboe/trek:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          environmentFiles = ["/run/opnix/trek-env"];
          volumes = [
            "/var/lib/trek/data:/app/data"
            "/var/lib/trek/uploads:/app/uploads"
          ];
          labels = self.lib.webLabels {
            host = "trek.jennex.dev";
            router = "trek";
            port = 3000;
            homepage = {
              group = "Home";
              name = "TREK";
              icon = "trek.png";
              description = "Travel Planner";
            };
          };
        };
      };
    };
  };
}
