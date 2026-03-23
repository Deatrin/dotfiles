# RoMM — ROM manager
#
# Secrets required (via opnix):
#   /run/opnix/romm-db-password          — shared MariaDB password (DB_PASSWD / MARIADB_PASSWORD)
#   /run/opnix/romm-db-root-password     — MariaDB root password
#   /run/opnix/romm-auth-secret-key      — auth secret key (openssl rand -hex 32)
#   /run/opnix/romm-screenscraper-user   — ScreenScraper username
#   /run/opnix/romm-screenscraper-pass   — ScreenScraper password
#   /run/opnix/romm-retroachievements-key — RetroAchievements API key
#   /run/opnix/romm-steamgriddb-key      — SteamGridDB API key
#   /run/opnix/romm-igdb-client-id       — IGDB client ID
#   /run/opnix/romm-igdb-client-secret   — IGDB client secret
#
# Media paths (/storage/media/games) are commented out — only available on nauvoo.
{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/romm/config 0755 root root -"
  ];

  # Build MariaDB env file
  systemd.services.romm-db-env-setup = {
    description = "Build RoMM MariaDB environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["romm-db.service"];
    wantedBy = ["romm-db.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "romm-db-env-setup";
        text = ''
          {
            printf 'MARIADB_ROOT_PASSWORD=%s\n' "$(cat /run/opnix/romm-db-root-password)"
            printf 'MARIADB_PASSWORD=%s\n'      "$(cat /run/opnix/romm-db-password)"
          } > /run/opnix/romm-db-env
          chmod 600 /run/opnix/romm-db-env
        '';
      });
    };
  };

  # Build RoMM app env file
  systemd.services.romm-env-setup = {
    description = "Build RoMM environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["romm.service"];
    wantedBy = ["romm.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "romm-env-setup";
        text = ''
          {
            printf 'DB_PASSWD=%s\n'                  "$(cat /run/opnix/romm-db-password)"
            printf 'ROMM_AUTH_SECRET_KEY=%s\n'       "$(cat /run/opnix/romm-auth-secret-key)"
            printf 'SCREENSCRAPER_USER=%s\n'         "$(cat /run/opnix/romm-screenscraper-user)"
            printf 'SCREENSCRAPER_PASSWORD=%s\n'     "$(cat /run/opnix/romm-screenscraper-pass)"
            printf 'RETROACHIEVEMENTS_API_KEY=%s\n'  "$(cat /run/opnix/romm-retroachievements-key)"
            printf 'STEAMGRIDDB_API_KEY=%s\n'        "$(cat /run/opnix/romm-steamgriddb-key)"
            printf 'IGDB_CLIENT_ID=%s\n'             "$(cat /run/opnix/romm-igdb-client-id)"
            printf 'IGDB_CLIENT_SECRET=%s\n'         "$(cat /run/opnix/romm-igdb-client-secret)"
            printf 'OIDC_CLIENT_ID=%s\n'             "$(cat /run/opnix/romm-oidc-client-id)"
            printf 'OIDC_CLIENT_SECRET=%s\n'         "$(cat /run/opnix/romm-oidc-client-secret)"
          } > /run/opnix/romm-env
          chmod 600 /run/opnix/romm-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    networks.romm_network = {};

    volumes = {
      romm-mysql = {};
      romm-resources = {};
      romm-redis = {};
    };

    containers.romm-db = {
      unitConfig = {
        After = ["opnix-secrets.service" "romm-db-env-setup.service"];
        Requires = ["opnix-secrets.service" "romm-db-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/library/mariadb:latest";
        autoUpdate = "registry";
        networks = [networks.romm_network.ref];
        environments = {
          MARIADB_DATABASE = "romm";
          MARIADB_USER = "romm-user";
        };
        environmentFiles = ["/run/opnix/romm-db-env"];
        volumes = ["${volumes.romm-mysql.ref}:/var/lib/mysql"];
      };
    };

    containers.romm = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "romm-env-setup.service"
          "romm-db.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "romm-env-setup.service"
          "romm-db.service"
        ];
      };
      containerConfig = {
        image = "docker.io/rommapp/romm:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref networks.romm_network.ref];
        environments = {
          DB_HOST = "romm-db";
          DB_NAME = "romm";
          DB_USER = "romm-user";
          HASHEOUS_API_ENABLED = "true";
          LAUNCHBOX_API_ENABLED = "true";
          PLAYMATCH_API_ENABLED = "true";
          FLASHPOINT_API_ENABLED = "true";
          HLTB_API_ENABLED = "true";
          OIDC_ENABLED = "true";
          OIDC_PROVIDER = "Pocket ID";
          OIDC_SERVER_APPLICATION_URL = "https://pocket.jennex.dev";
          OIDC_REDIRECT_URI = "https://romm.jennex.dev/api/oauth/openid/callback";
        };
        environmentFiles = ["/run/opnix/romm-env"];
        volumes = [
          "${volumes.romm-resources.ref}:/romm/resources"
          "${volumes.romm-redis.ref}:/redis-data"
          "/var/lib/romm/config:/romm/config"
          "/storage/media/games/romm/library:/romm/library"
          "/storage/media/games/romm/assets:/romm/assets"
        ];
        labels = [
          "homepage.group=Dev & Games"
          "homepage.name=RoMM"
          "homepage.icon=romm.png"
          "homepage.href=https://romm.jennex.dev"
          "homepage.description=ROM Manager"
          "traefik.enable=true"
          "traefik.http.routers.romm.rule=Host(`romm.jennex.dev`)"
          "traefik.http.routers.romm-secure.entrypoints=https"
          "traefik.http.routers.romm-secure.rule=Host(`romm.jennex.dev`)"
          "traefik.http.routers.romm-secure.tls=true"
          "traefik.http.services.romm.loadbalancer.server.port=8080"
        ];
      };
    };
  };
}
