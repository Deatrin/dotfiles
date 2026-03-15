# NetBox — Network source of truth (DCIM + IPAM)
#
# Secrets required (via opnix):
#   /run/opnix/netbox-secret-key            — Django SECRET_KEY
#   /run/opnix/netbox-db-password           — PostgreSQL password
#   /run/opnix/netbox-redis-password        — Primary Redis password
#   /run/opnix/netbox-redis-cache-password  — Cache Redis password
#   /run/opnix/netbox-superuser-name        — Admin username
#   /run/opnix/netbox-superuser-password    — Admin password
#   /run/opnix/netbox-superuser-email       — Admin email
#   /run/opnix/netbox-superuser-api-token   — Admin API token
#
# Storage:
#   Named volumes: netbox-postgres, netbox-redis, netbox-redis-cache,
#                  netbox-media, netbox-reports, netbox-scripts
#
# Routing (via Traefik):
#   netbox.jennex.dev → netbox:8080
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
  domain = "netbox.jennex.dev";
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/netbox 0755 root root -"
  ];

  # Build PostgreSQL env file
  systemd.services.netbox-db-env-setup = {
    description = "Build NetBox PostgreSQL environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["netbox-postgres.service"];
    wantedBy = ["netbox-postgres.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "netbox-db-env-setup";
        text = ''
          {
            printf 'POSTGRES_DB=netbox\n'
            printf 'POSTGRES_USER=netbox\n'
            printf 'POSTGRES_PASSWORD=%s\n' "$(cat /run/opnix/netbox-db-password)"
          } > /run/opnix/netbox-db-env
          chmod 600 /run/opnix/netbox-db-env
        '';
      });
    };
  };

  # Write Redis config file (requirepass must be set via config, not env var)
  systemd.services.netbox-redis-env-setup = {
    description = "Build NetBox Redis config file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["netbox-redis.service"];
    wantedBy = ["netbox-redis.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "netbox-redis-env-setup";
        text = ''
          {
            printf 'appendonly yes\n'
            printf 'requirepass %s\n' "$(cat /run/opnix/netbox-redis-password)"
          } > /run/opnix/netbox-redis.conf
          chmod 644 /run/opnix/netbox-redis.conf
        '';
      });
    };
  };

  # Write Redis cache config file
  systemd.services.netbox-redis-cache-env-setup = {
    description = "Build NetBox Redis cache config file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["netbox-redis-cache.service"];
    wantedBy = ["netbox-redis-cache.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "netbox-redis-cache-env-setup";
        text = ''
          {
            printf 'appendonly yes\n'
            printf 'requirepass %s\n' "$(cat /run/opnix/netbox-redis-cache-password)"
          } > /run/opnix/netbox-redis-cache.conf
          chmod 644 /run/opnix/netbox-redis-cache.conf
        '';
      });
    };
  };

  # Build NetBox app env file
  systemd.services.netbox-app-env-setup = {
    description = "Build NetBox application environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["netbox.service"];
    wantedBy = ["netbox.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "netbox-app-env-setup";
        text = ''
          {
            printf 'SECRET_KEY=%s\n'             "$(cat /run/opnix/netbox-secret-key)"
            printf 'DB_PASSWORD=%s\n'            "$(cat /run/opnix/netbox-db-password)"
            printf 'REDIS_PASSWORD=%s\n'         "$(cat /run/opnix/netbox-redis-password)"
            printf 'REDIS_CACHE_PASSWORD=%s\n'   "$(cat /run/opnix/netbox-redis-cache-password)"
            printf 'SUPERUSER_NAME=%s\n'         "$(cat /run/opnix/netbox-superuser-name)"
            printf 'SUPERUSER_PASSWORD=%s\n'     "$(cat /run/opnix/netbox-superuser-password)"
            printf 'SUPERUSER_EMAIL=%s\n'        "$(cat /run/opnix/netbox-superuser-email)"
            printf 'SUPERUSER_API_TOKEN=%s\n'    "$(cat /run/opnix/netbox-superuser-api-token)"
          } > /run/opnix/netbox-app-env
          chmod 600 /run/opnix/netbox-app-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    networks.netbox_network = {};

    volumes = {
      netbox-postgres = {};
      netbox-redis = {};
      netbox-redis-cache = {};
      netbox-media = {};
      netbox-reports = {};
      netbox-scripts = {};
    };

    containers.netbox-postgres = {
      unitConfig = {
        After = ["opnix-secrets.service" "netbox-db-env-setup.service"];
        Requires = ["opnix-secrets.service" "netbox-db-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/postgres:18-alpine";
        autoUpdate = "registry";
        networks = [networks.netbox_network.ref];
        environmentFiles = ["/run/opnix/netbox-db-env"];
        volumes = ["${volumes.netbox-postgres.ref}:/var/lib/postgresql/data"];
      };
    };

    containers.netbox-redis = {
      unitConfig = {
        After = ["opnix-secrets.service" "netbox-redis-env-setup.service"];
        Requires = ["opnix-secrets.service" "netbox-redis-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/valkey/valkey:9.0-alpine";
        autoUpdate = "registry";
        networks = [networks.netbox_network.ref];
        exec = "valkey-server /etc/valkey/valkey.conf";
        volumes = [
          "${volumes.netbox-redis.ref}:/data"
          "/run/opnix/netbox-redis.conf:/etc/valkey/valkey.conf:ro"
        ];
      };
    };

    containers.netbox-redis-cache = {
      unitConfig = {
        After = ["opnix-secrets.service" "netbox-redis-cache-env-setup.service"];
        Requires = ["opnix-secrets.service" "netbox-redis-cache-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/valkey/valkey:9.0-alpine";
        autoUpdate = "registry";
        networks = [networks.netbox_network.ref];
        exec = "valkey-server /etc/valkey/valkey.conf";
        volumes = [
          "${volumes.netbox-redis-cache.ref}:/data"
          "/run/opnix/netbox-redis-cache.conf:/etc/valkey/valkey.conf:ro"
        ];
      };
    };

    containers.netbox = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "netbox-app-env-setup.service"
          "netbox-postgres.service"
          "netbox-redis.service"
          "netbox-redis-cache.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "netbox-app-env-setup.service"
          "netbox-postgres.service"
          "netbox-redis.service"
          "netbox-redis-cache.service"
        ];
      };
      containerConfig = {
        image = "docker.io/netboxcommunity/netbox:latest";
        autoUpdate = "registry";
        networks = [networks.netbox_network.ref networks.traefik_network.ref];
        environments = {
          DB_HOST = "netbox-postgres";
          DB_NAME = "netbox";
          DB_USER = "netbox";
          REDIS_HOST = "netbox-redis";
          REDIS_DATABASE = "0";
          REDIS_SSL = "false";
          REDIS_INSECURE_SKIP_TLS_VERIFY = "false";
          REDIS_CACHE_HOST = "netbox-redis-cache";
          REDIS_CACHE_DATABASE = "1";
          REDIS_CACHE_SSL = "false";
          REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY = "false";
          SKIP_SUPERUSER = "false";
          CORS_ORIGIN_ALLOW_ALL = "True";
          TZ = "America/Los_Angeles";
        };
        environmentFiles = ["/run/opnix/netbox-app-env"];
        volumes = [
          "${volumes.netbox-media.ref}:/opt/netbox/netbox/media"
          "${volumes.netbox-reports.ref}:/opt/netbox/netbox/reports"
          "${volumes.netbox-scripts.ref}:/opt/netbox/netbox/scripts"
        ];
        labels = [
          "homepage.group=Network"
          "homepage.name=NetBox"
          "homepage.icon=netbox.png"
          "homepage.href=https://${domain}"
          "homepage.description=Network Source of Truth"
          "traefik.enable=true"
          "traefik.http.routers.netbox-secure.entrypoints=https"
          "traefik.http.routers.netbox-secure.rule=Host(`${domain}`)"
          "traefik.http.routers.netbox-secure.tls=true"
          "traefik.http.services.netbox.loadbalancer.server.port=8080"
        ];
      };
    };

    containers.netbox-worker = {
      unitConfig = {
        After = ["netbox.service"];
        Requires = ["netbox.service"];
      };
      containerConfig = {
        image = "docker.io/netboxcommunity/netbox:latest";
        autoUpdate = "registry";
        networks = [networks.netbox_network.ref];
        exec = "/opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py rqworker";
        environments = {
          DB_HOST = "netbox-postgres";
          DB_NAME = "netbox";
          DB_USER = "netbox";
          REDIS_HOST = "netbox-redis";
          REDIS_DATABASE = "0";
          REDIS_SSL = "false";
          REDIS_INSECURE_SKIP_TLS_VERIFY = "false";
          REDIS_CACHE_HOST = "netbox-redis-cache";
          REDIS_CACHE_DATABASE = "1";
          REDIS_CACHE_SSL = "false";
          REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY = "false";
          TZ = "America/Los_Angeles";
        };
        environmentFiles = ["/run/opnix/netbox-app-env"];
        volumes = [
          "${volumes.netbox-media.ref}:/opt/netbox/netbox/media"
          "${volumes.netbox-reports.ref}:/opt/netbox/netbox/reports"
          "${volumes.netbox-scripts.ref}:/opt/netbox/netbox/scripts"
        ];
      };
    };
  };
}
