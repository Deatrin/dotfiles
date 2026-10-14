# Paperless-ngx — document management
#
# Secrets required (via opnix):
#   /run/opnix/paperless-secret  — env file containing:
#       PAPERLESS_SECRET_KEY=<long random string>
{self, ...}: {
  flake.modules.nixos.paperless = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.paperless;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.paperless.enable = lib.mkEnableOption "Paperless-ngx document management";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet = {
        networks.paperless_network = {};

        volumes = {
          paperless-redis = {};
          paperless-pgdata = {};
        };

        # Redis broker
        containers.paperless-broker = {
          containerConfig = {
            image = "docker.io/library/redis:8";
            autoUpdate = "registry";
            networks = [networks.paperless_network.ref];
            volumes = ["${volumes.paperless-redis.ref}:/data"];
          };
        };

        # PostgreSQL — no password needed, internal network only
        containers.paperless-db = {
          containerConfig = {
            image = "docker.io/library/postgres:17";
            autoUpdate = "registry";
            networks = [networks.paperless_network.ref];
            environments = {
              POSTGRES_DB = "paperless";
              POSTGRES_USER = "paperless";
              POSTGRES_HOST_AUTH_METHOD = "trust";
            };
            volumes = ["${volumes.paperless-pgdata.ref}:/var/lib/postgresql/data"];
          };
        };

        # Paperless webserver
        containers.paperless = {
          unitConfig = {
            After = [
              "opnix-secrets.service"
              "paperless-db.service"
              "paperless-broker.service"
            ];
            Requires = [
              "opnix-secrets.service"
              "paperless-db.service"
              "paperless-broker.service"
            ];
          };
          containerConfig = {
            image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
            autoUpdate = "registry";
            networks = [networks.traefik_network.ref networks.paperless_network.ref];
            environments = {
              PAPERLESS_REDIS = "redis://paperless-broker:6379";
              PAPERLESS_DBHOST = "paperless-db";
              PAPERLESS_DBUSER = "paperless";
              PAPERLESS_DBNAME = "paperless";
              PAPERLESS_URL = "https://paperless.jennex.dev";
              PAPERLESS_TIME_ZONE = "America/Los_Angeles";
              PAPERLESS_OCR_LANGUAGE = "eng";
              PAPERLESS_CONSUMER_POLLING = "300";
              PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
              PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = "true";
              PAPERLESS_SOCIALACCOUNT_EMAIL_AUTHENTICATION = "true";
              PAPERLESS_SOCIALACCOUNT_EMAIL_REQUIRED = "true";
              PAPERLESS_CSRF_ALLOWED_ORIGINS = "https://paperless.jennex.dev";
              PAPERLESS_ALLOWED_HOSTS = "paperless.jennex.dev";
              PAPERLESS_USE_X_FORWARDED_HOST = "true";
              PAPERLESS_USE_X_FORWARDED_PORT = "true";
            };
            environmentFiles = ["/run/opnix/paperless-secret"];
            volumes = [
              "/storage/media/documents/paperless/data:/usr/src/paperless/data"
              "/storage/media/documents/paperless/media:/usr/src/paperless/media"
              "/storage/media/documents/paperless/export:/usr/src/paperless/export"
              "/storage/media/documents/paperless/consume:/usr/src/paperless/consume"
            ];
            labels = self.lib.webLabels {
              host = "paperless.jennex.dev";
              router = "paperless";
              port = 8000;
              homepage = {
                group = "Home";
                name = "Paperless";
                icon = "paperless-ngx.png";
                description = "Documents";
              };
            };
          };
        };
      };
    };
  };
}
