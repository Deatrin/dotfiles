# Nextcloud — file hosting and browsing
#
# Secrets required (via opnix):
#   /run/opnix/nextcloud-env — env file containing:
#       NEXTCLOUD_ADMIN_PASSWORD=<password>
#   /run/opnix/nextcloud-oidc-client-id
#   /run/opnix/nextcloud-oidc-client-secret
#
# On first run, log in as admin/admin-password and add External Storage:
#   Apps → External Storage Support (enable)
#   Admin → External Storages → Add: Local, /storage/media
#
# OIDC: install the nextcloud-oidc-login app from the app store
#   Pocket ID callback URL: https://nextcloud.jennex.dev/apps/oidc_login/oidc
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
  oidcConfig = pkgs.writeText "nextcloud-oidc.php" ''
    <?php
    $CONFIG = [
      'oidc_login_provider_url'    => 'https://pocket.jennex.dev',
      'oidc_login_client_id'       => trim(file_get_contents('/run/opnix/nextcloud-oidc-client-id')),
      'oidc_login_client_secret'   => trim(file_get_contents('/run/opnix/nextcloud-oidc-client-secret')),
      'oidc_login_auto_redirect'   => false,
      'oidc_login_button_text'     => 'Sign in with Pocket ID',
      'oidc_login_scope'           => 'openid profile email',
      'oidc_login_attributes'      => [
        'id'   => 'preferred_username',
        'name' => 'name',
        'mail' => 'email',
      ],
    ];
  '';
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/nextcloud 0755 root root -"
  ];

  systemd.services.nextcloud-env-setup = {
    description = "Build Nextcloud environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["nextcloud.service"];
    wantedBy = ["nextcloud.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "nextcloud-env-setup";
        text = ''
          {
            printf 'NEXTCLOUD_ADMIN_PASSWORD=%s\n' "$(cat /run/opnix/nextcloud-admin-password)"
            printf 'POSTGRES_PASSWORD=internal\n'
          } > /run/opnix/nextcloud-env
          chmod 600 /run/opnix/nextcloud-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    networks.nextcloud_network = {};

    volumes.nextcloud-pgdata = {};

    # PostgreSQL sidecar — trust auth, internal network only
    containers.nextcloud-db = {
      containerConfig = {
        image = "docker.io/library/postgres:17";
        autoUpdate = "registry";
        networks = [networks.nextcloud_network.ref];
        environments = {
          POSTGRES_DB = "nextcloud";
          POSTGRES_USER = "nextcloud";
          POSTGRES_HOST_AUTH_METHOD = "trust";
        };
        volumes = ["${volumes.nextcloud-pgdata.ref}:/var/lib/postgresql/data"];
      };
    };

    # Redis cache
    containers.nextcloud-redis = {
      containerConfig = {
        image = "docker.io/library/redis:7-alpine";
        autoUpdate = "registry";
        networks = [networks.nextcloud_network.ref];
      };
    };

    # Nextcloud
    containers.nextcloud = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "nextcloud-env-setup.service"
          "nextcloud-db.service"
          "nextcloud-redis.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "nextcloud-env-setup.service"
          "nextcloud-db.service"
          "nextcloud-redis.service"
        ];
      };
      containerConfig = {
        image = "docker.io/library/nextcloud:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref networks.nextcloud_network.ref];
        environments = {
          NEXTCLOUD_ADMIN_USER = "admin";
          NEXTCLOUD_TRUSTED_DOMAINS = "nextcloud.jennex.dev";
          POSTGRES_HOST = "nextcloud-db";
          POSTGRES_DB = "nextcloud";
          POSTGRES_USER = "nextcloud";
          REDIS_HOST = "nextcloud-redis";
          PHP_MEMORY_LIMIT = "512M";
          PHP_UPLOAD_LIMIT = "10G";
          TZ = "America/Los_Angeles";
        };
        environmentFiles = ["/run/opnix/nextcloud-env"];
        volumes = [
          "/var/lib/nextcloud:/var/www/html"
          "/storage/media:/storage/media"
          "${oidcConfig}:/var/www/html/config/oidc.config.php:ro"
          "/run/opnix/nextcloud-oidc-client-id:/run/opnix/nextcloud-oidc-client-id:ro"
          "/run/opnix/nextcloud-oidc-client-secret:/run/opnix/nextcloud-oidc-client-secret:ro"
        ];
        labels = [
          "homepage.group=System"
          "homepage.name=Nextcloud"
          "homepage.icon=nextcloud.png"
          "homepage.href=https://nextcloud.jennex.dev"
          "homepage.description=File Browser"
          "traefik.enable=true"
          "traefik.http.routers.nextcloud.rule=Host(`nextcloud.jennex.dev`)"
          "traefik.http.routers.nextcloud-secure.entrypoints=https"
          "traefik.http.routers.nextcloud-secure.rule=Host(`nextcloud.jennex.dev`)"
          "traefik.http.routers.nextcloud-secure.tls=true"
          "traefik.http.services.nextcloud.loadbalancer.server.port=80"
        ];
      };
    };
  };
}
