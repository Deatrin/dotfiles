# Seerr — media request management (formerly Jellyseerr)
#
# No secrets required — all configuration stored in volume.
{self, ...}: {
  flake.modules.nixos.seerr = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.seerr;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.seerr.enable = lib.mkEnableOption "Seerr media request management";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/seerr 0755 root root -"
      ];

      virtualisation.quadlet = {
        volumes.seerr-config = {};

        containers.seerr = {
          containerConfig = {
            image = "ghcr.io/seerr-team/seerr:latest";
            autoUpdate = "registry";
            networks = [networks.traefik_network.ref];
            environments = {
              LOG_LEVEL = "debug";
              TZ = "America/Los_Angeles";
              PORT = "5055";
            };
            volumes = ["${volumes.seerr-config.ref}:/app/config"];
            labels = self.lib.webLabels {
              host = "seerr.jennex.dev";
              router = "seerr";
              port = 5055;
              homepage = {
                group = "Downloads";
                name = "Seerr";
                icon = "jellyseerr.png";
                description = "Media Requests";
              };
            };
          };
        };
      };
    };
  };
}
