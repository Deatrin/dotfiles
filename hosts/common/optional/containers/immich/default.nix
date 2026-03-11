# Immich — photo management
#
# Secrets required (via opnix):
#   /run/opnix/immich-env  — env file containing:
#       DB_PASSWORD=<password>
{
  config,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {

  virtualisation.quadlet = {
    networks.immich_network = {};

    volumes = {
      immich-model-cache = {};
      immich-pgdata = {};
    };

    # Valkey (Redis-compatible)
    containers.immich-redis = {
      containerConfig = {
        image = "docker.io/valkey/valkey:9";
        autoUpdate = "registry";
        networks = [networks.immich_network.ref];
      };
    };

    # Custom Postgres with pgvectors — no password, internal network only
    containers.immich-db = {
      containerConfig = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
        autoUpdate = "registry";
        networks = [networks.immich_network.ref];
        environments = {
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "immich";
          POSTGRES_HOST_AUTH_METHOD = "trust";
          POSTGRES_INITDB_ARGS = "--data-checksums";
        };
        volumes = ["${volumes.immich-pgdata.ref}:/var/lib/postgresql/data"];
      };
    };

    # Machine learning
    containers.immich-ml = {
      unitConfig = {
        After = ["opnix-secrets.service"];
        Requires = ["opnix-secrets.service"];
      };
      containerConfig = {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        autoUpdate = "registry";
        networks = [networks.immich_network.ref];
        environmentFiles = ["/run/opnix/immich-env"];
        volumes = ["${volumes.immich-model-cache.ref}:/cache"];
      };
    };

    # Immich server
    containers.immich-server = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "immich-db.service"
          "immich-redis.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "immich-db.service"
          "immich-redis.service"
        ];
      };
      containerConfig = {
        image = "ghcr.io/immich-app/immich-server:release";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref networks.immich_network.ref];
        environments = {
          DB_HOSTNAME = "immich-db";
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          REDIS_HOSTNAME = "immich-redis";
        };
        environmentFiles = ["/run/opnix/immich-env"];
        volumes = [
          "/storage/media/photos/immich:/usr/src/app/upload"
          "/etc/localtime:/etc/localtime:ro"
        ];
        labels = [
          "homepage.group=Photos"
          "homepage.name=Immich"
          "homepage.icon=immich.png"
          "homepage.href=https://immich.jennex.dev"
          "homepage.description=Photo Management"
          "traefik.enable=true"
          "traefik.http.routers.immich.rule=Host(`immich.jennex.dev`)"
          "traefik.http.routers.immich-secure.entrypoints=https"
          "traefik.http.routers.immich-secure.rule=Host(`immich.jennex.dev`)"
          "traefik.http.routers.immich-secure.tls=true"
          "traefik.http.services.immich.loadbalancer.server.port=2283"
        ];
      };
    };
  };
}
