# Tasterr — household discovery front end for TMDB/Plex/Seerr
# https://github.com/ZacharyArthur/tasterr
#
# Storage is SQLite on the tasterr-data volume (/data/tasterr.db).
# Sign-in and requests go through Seerr (2.x requires it), reached over
# traefik_network by container name — so dotfiles.seerr.enable must also be true.
#
# Secrets required (via op-connect-secrets, see hosts/nixos/nauvoo/secrets.nix):
#   /run/opnix/tasterr-env  — env file containing:
#       TMDB_API_KEY=<TMDB v3 API key>
#       TASTERR_SECRET_KEY=<random string, e.g. openssl rand -base64 32>
#           (encrypts stored Plex tokens/Seerr cookies — rotating it forces re-linking)
#       SEERR_API_KEY=<Seerr → Settings → General>
{self, ...}: {
  flake.modules.nixos.tasterr = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.dotfiles.tasterr;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.tasterr.enable = lib.mkEnableOption "Tasterr media discovery";

    config = lib.mkIf cfg.enable {
      systemd.services.tasterr-env-setup = {
        description = "Build Tasterr environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["tasterr.service"];
        wantedBy = ["tasterr.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "tasterr-env-setup";
            text = ''
              {
                printf 'TMDB_API_KEY=%s\n'       "$(cat /run/opnix/tasterr-tmdb-api-key)"
                printf 'TASTERR_SECRET_KEY=%s\n' "$(cat /run/opnix/tasterr-secret-key)"
                printf 'SEERR_API_KEY=%s\n'      "$(cat /run/opnix/tasterr-seerr-api-key)"
              } > /run/opnix/tasterr-env
              chmod 600 /run/opnix/tasterr-env
            '';
          });
        };
      };

      virtualisation.quadlet = {
        volumes.tasterr-data = {};

        containers.tasterr = {
          unitConfig = {
            After = ["opnix-secrets.service" "tasterr-env-setup.service" "seerr.service"];
            Requires = ["opnix-secrets.service" "tasterr-env-setup.service"];
          };
          containerConfig = {
            image = "ghcr.io/zacharyarthur/tasterr:latest";
            autoUpdate = "registry";
            networks = [networks.traefik_network.ref];
            environments = {
              SEERR_INTERNAL_URL = "http://seerr:5055";
              SEERR_EXTERNAL_URL = "https://seerr.jennex.dev";
              # Trust Traefik's X-Forwarded-Proto so session cookies are Secure;
              # without it logins loop behind HTTPS. Podman allocates named
              # networks out of 10.89.0.0/16 and traefik_network's /24 isn't
              # pinned, so trust the whole pool rather than a guessed subnet.
              TASTERR_FORWARDED_ALLOW_IPS = "10.89.0.0/16";
            };
            environmentFiles = ["/run/opnix/tasterr-env"];
            volumes = ["${volumes.tasterr-data.ref}:/data"];
            labels = self.lib.webLabels {
              host = "tasterr.jennex.dev";
              router = "tasterr";
              port = 8000;
              homepage = {
                group = "Downloads";
                name = "Tasterr";
                icon = "sh-tasterr.png";
                description = "Media Discovery";
              };
            };
          };
        };
      };
    };
  };
}
