# Manyfold — 3D model file manager
#
# Secrets required (via opnix):
#   /run/opnix/manyfold-db-password      — PostgreSQL password
#   /run/opnix/manyfold-secret-key-base  — Rails secret key base (openssl rand -hex 64)
#
# Storage paths:
#   /storage/media/manyfold/models       — 3D model storage
#
# Routing (via Traefik):
#   manyfold.jennex.dev → manyfold:3214
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
  domain = "manyfold.jennex.dev";
in {
  systemd.tmpfiles.rules = [
    "d /storage/media/manyfold/models 0755 root root -"
  ];

  systemd.services.manyfold-env-setup = {
    description = "Build Manyfold environment files from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["manyfold-postgres.service" "manyfold.service"];
    wantedBy = ["manyfold-postgres.service" "manyfold.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "manyfold-env-setup";
        text = ''
          {
            printf 'POSTGRES_PASSWORD=%s\n' "$(cat /run/opnix/manyfold-db-password)"
          } > /run/opnix/manyfold-postgres-env
          chmod 600 /run/opnix/manyfold-postgres-env

          {
            printf 'DATABASE_PASSWORD=%s\n' "$(cat /run/opnix/manyfold-db-password)"
            printf 'SECRET_KEY_BASE=%s\n'   "$(cat /run/opnix/manyfold-secret-key-base)"
          } > /run/opnix/manyfold-env
          chmod 600 /run/opnix/manyfold-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    networks.manyfold_network = {};

    volumes.manyfold-postgres = {};

    containers.manyfold-postgres = {
      unitConfig = {
        After = ["opnix-secrets.service" "manyfold-env-setup.service"];
        Requires = ["opnix-secrets.service" "manyfold-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/library/postgres:15";
        autoUpdate = "registry";
        networks = [networks.manyfold_network.ref];
        environments = {
          POSTGRES_USER = "manyfold";
          POSTGRES_DB = "manyfold";
        };
        environmentFiles = ["/run/opnix/manyfold-postgres-env"];
        volumes = ["${volumes.manyfold-postgres.ref}:/var/lib/postgresql/data"];
      };
    };

    containers.manyfold-redis = {
      containerConfig = {
        image = "docker.io/library/redis:7";
        autoUpdate = "registry";
        networks = [networks.manyfold_network.ref];
      };
    };

    containers.manyfold = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "manyfold-env-setup.service"
          "manyfold-postgres.service"
          "manyfold-redis.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "manyfold-env-setup.service"
          "manyfold-postgres.service"
          "manyfold-redis.service"
        ];
      };
      containerConfig = {
        image = "ghcr.io/manyfold3d/manyfold:latest";
        autoUpdate = "registry";
        networks = [networks.manyfold_network.ref networks.traefik_network.ref];
        environments = {
          DATABASE_ADAPTER = "postgresql";
          DATABASE_HOST = "manyfold-postgres";
          DATABASE_NAME = "manyfold";
          DATABASE_USER = "manyfold";
          REDIS_URL = "redis://manyfold-redis:6379/1";
          PUID = "1000";
          PGID = "1000";
        };
        environmentFiles = ["/run/opnix/manyfold-env"];
        volumes = ["/storage/media/manyfold/models:/models"];
        labels = [
          "homepage.group=Home"
          "homepage.name=Manyfold"
          "homepage.icon=manyfold.png"
          "homepage.href=https://${domain}"
          "homepage.description=3D Model Manager"
          "traefik.enable=true"
          "traefik.http.routers.manyfold-secure.entrypoints=https"
          "traefik.http.routers.manyfold-secure.rule=Host(`${domain}`)"
          "traefik.http.routers.manyfold-secure.tls=true"
          "traefik.http.services.manyfold.loadbalancer.server.port=3214"
        ];
      };
    };
  };
}
