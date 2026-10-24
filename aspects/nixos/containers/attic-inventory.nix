# Attic — home inventory (https://github.com/lmmendes/attic)
#
# Not the Attic Nix binary cache (attic-server.nix / cache.jennex.dev) — hence
# the attic-inventory name everywhere except the hostname.
#
# Two containers: attic-inventory (Go backend with the UI embedded, runs its
# own DB migrations on start) and attic-inventory-db (Postgres, trust auth on
# a private network). Attachments use local storage on a named volume.
#
# Secrets required (via op-connect-secrets, see hosts/nixos/nauvoo/secrets.nix):
#   /run/opnix/attic-inventory-env  — env file containing:
#       ATTIC_SESSION_SECRET=<random string, 32+ chars>
#       ATTIC_ADMIN_PASSWORD=<first local admin's password; only read while no users exist>
#       ATTIC_OIDC_CLIENT_ID=<Pocket ID OIDC client ID>
#       ATTIC_OIDC_CLIENT_SECRET=<Pocket ID OIDC client secret>
#       ATTIC_TMDB_API_KEY=<TMDB v3 key — shared with Tasterr's 1Password item>
#
# Pocket ID setup:
#   OIDC client callback URL: https://attic.jennex.dev/auth/oidc/callback
#
# Local fallback login: user "admin" with ATTIC_ADMIN_PASSWORD.
{self, ...}: {
  flake.modules.nixos.attic-inventory = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.dotfiles.attic-inventory;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.attic-inventory.enable = lib.mkEnableOption "Attic home inventory";

    config = lib.mkIf cfg.enable {
      systemd.services.attic-inventory-env-setup = {
        description = "Build Attic inventory environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["attic-inventory.service"];
        wantedBy = ["attic-inventory.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "attic-inventory-env-setup";
            # Read into variables first: a failed $(cat) in an assignment
            # aborts under errexit, where inside printf's arguments it would
            # silently write an empty value.
            text = ''
              session_secret=$(cat /run/opnix/attic-inventory-session-secret)
              admin_password=$(cat /run/opnix/attic-inventory-admin-password)
              oidc_client_id=$(cat /run/opnix/attic-inventory-oidc-client-id)
              oidc_client_secret=$(cat /run/opnix/attic-inventory-oidc-client-secret)
              tmdb_api_key=$(cat /run/opnix/attic-inventory-tmdb-api-key)
              {
                printf 'ATTIC_SESSION_SECRET=%s\n'     "$session_secret"
                printf 'ATTIC_ADMIN_PASSWORD=%s\n'     "$admin_password"
                printf 'ATTIC_OIDC_CLIENT_ID=%s\n'     "$oidc_client_id"
                printf 'ATTIC_OIDC_CLIENT_SECRET=%s\n' "$oidc_client_secret"
                printf 'ATTIC_TMDB_API_KEY=%s\n'       "$tmdb_api_key"
              } > /run/opnix/attic-inventory-env
              chmod 600 /run/opnix/attic-inventory-env
            '';
          });
        };
      };

      virtualisation.quadlet = {
        networks.attic_inventory_network = {};

        volumes = {
          attic-inventory-pgdata = {};
          attic-inventory-uploads = {};
        };

        # PostgreSQL — no password needed, internal network only
        containers.attic-inventory-db = {
          containerConfig = {
            image = "docker.io/library/postgres:17";
            autoUpdate = "registry";
            networks = [networks.attic_inventory_network.ref];
            environments = {
              POSTGRES_DB = "attic";
              POSTGRES_USER = "attic";
              POSTGRES_HOST_AUTH_METHOD = "trust";
            };
            volumes = ["${volumes.attic-inventory-pgdata.ref}:/var/lib/postgresql/data"];
          };
        };

        containers.attic-inventory = {
          unitConfig = {
            After = [
              "opnix-secrets.service"
              "attic-inventory-env-setup.service"
              "attic-inventory-db.service"
            ];
            Requires = [
              "opnix-secrets.service"
              "attic-inventory-env-setup.service"
              "attic-inventory-db.service"
            ];
          };
          containerConfig = {
            image = "ghcr.io/lmmendes/attic:latest";
            autoUpdate = "registry";
            networks = [
              networks.traefik_network.ref
              networks.attic_inventory_network.ref
            ];
            environments = {
              ATTIC_PORT = "8080";
              ATTIC_DATABASE_URL = "postgres://attic@attic-inventory-db:5432/attic?sslmode=disable";
              ATTIC_BASE_URL = "https://attic.jennex.dev";
              ATTIC_CORS_ORIGINS = "https://attic.jennex.dev";
              ATTIC_LOCAL_STORAGE_PATH = "/data/uploads";
              ATTIC_OIDC_ISSUER_URL = "https://pocket.jennex.dev";
              TZ = "America/Los_Angeles";
            };
            environmentFiles = ["/run/opnix/attic-inventory-env"];
            volumes = ["${volumes.attic-inventory-uploads.ref}:/data/uploads"];
            labels = self.lib.webLabels {
              host = "attic.jennex.dev";
              router = "attic-inventory";
              port = 8080;
              homepage = {
                group = "Home";
                name = "Attic";
                icon = "sh-attic-assets.png";
                description = "Home Inventory";
              };
            };
          };
        };
      };
    };
  };
}
