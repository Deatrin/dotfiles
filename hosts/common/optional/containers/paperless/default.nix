# Paperless-ngx — document management
#
# Secrets required (via opnix):
#   /run/opnix/paperless-secret  — env file containing:
#       PAPERLESS_SECRET_KEY=<long random string>
#
# On nauvoo, replace /var/lib/paperless/* volume paths with:
#   /storage/media/documents/paperless/{data,media,export,consume}
{
  config,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/paperless/data    0755 root root -"
    "d /var/lib/paperless/media   0755 root root -"
    "d /var/lib/paperless/export  0755 root root -"
    "d /var/lib/paperless/consume 0755 root root -"
  ];

  virtualisation.quadlet = {
    networks.paperless_network = {};

    volumes = {
      paperless-redis = {};
      paperless-pgdata = {};
    };

    # Redis broker
    containers.paperless-broker = {
      containerConfig = {
        image = "docker.io/library/redis:7";
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
          PAPERLESS_URL = "https://paperless.deatrin.dev";
          PAPERLESS_TIME_ZONE = "America/Los_Angeles";
          PAPERLESS_OCR_LANGUAGE = "eng";
          PAPERLESS_CONSUMER_POLLING = "300";
        };
        environmentFiles = ["/run/opnix/paperless-secret"];
        volumes = [
          # On nauvoo replace with /storage/media/documents/paperless/{data,media,export,consume}
          "/var/lib/paperless/data:/usr/src/paperless/data"
          "/var/lib/paperless/media:/usr/src/paperless/media"
          "/var/lib/paperless/export:/usr/src/paperless/export"
          "/var/lib/paperless/consume:/usr/src/paperless/consume"
        ];
        labels = [
          "homepage.group=Self-Hosted"
          "homepage.name=Paperless"
          "homepage.icon=paperless-ngx.png"
          "homepage.href=https://paperless.deatrin.dev"
          "homepage.description=Documents"
          "traefik.enable=true"
          "traefik.http.routers.paperless.rule=Host(`paperless.deatrin.dev`)"
          "traefik.http.routers.paperless-secure.entrypoints=https"
          "traefik.http.routers.paperless-secure.rule=Host(`paperless.deatrin.dev`)"
          "traefik.http.routers.paperless-secure.tls=true"
          "traefik.http.services.paperless.loadbalancer.server.port=8000"
        ];
      };
    };
  };
}
