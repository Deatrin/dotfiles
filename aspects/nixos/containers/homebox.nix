{self, ...}: {
  flake.modules.nixos.homebox = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.dotfiles.homebox;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.homebox.enable = lib.mkEnableOption "Homebox home inventory";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/homebox 0755 root root -"
      ];

      systemd.services.homebox-env-setup = {
        description = "Build Homebox environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["homebox.service"];
        wantedBy = ["homebox.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "homebox-env-setup";
            text = ''
              printf 'HBOX_AUTH_API_KEY_PEPPER=%s\n' \
                "$(cat /run/opnix/homebox-api-key-pepper)" \
                > /run/opnix/homebox-env
              chmod 600 /run/opnix/homebox-env
            '';
          });
        };
      };

      virtualisation.quadlet.containers.homebox = {
        unitConfig = {
          After = ["opnix-secrets.service" "homebox-env-setup.service"];
          Requires = ["opnix-secrets.service" "homebox-env-setup.service"];
        };
        containerConfig = {
          image = "ghcr.io/sysadminsmedia/homebox:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          environments = {
            HBOX_LOG_LEVEL = "info";
            HBOX_LOG_FORMAT = "text";
            HBOX_WEB_MAX_UPLOAD_SIZE = "10";
            HBOX_OPTIONS_ALLOW_ANALYTICS = "false";
          };
          environmentFiles = ["/run/opnix/homebox-env"];
          volumes = ["/var/lib/homebox:/data"];
          labels = self.lib.webLabels {
            host = "homebox.jennex.dev";
            router = "homebox";
            port = 7745;
            homepage = {
              group = "Home";
              name = "homebox";
              icon = "homebox.png";
              description = "Home Inventory";
            };
          };
        };
      };
    };
  };
}
