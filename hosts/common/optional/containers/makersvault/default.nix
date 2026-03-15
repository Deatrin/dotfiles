# MakersVault — 3D print file manager
#
# Secrets required (via opnix):
#   /run/opnix/makersvault-env — env file containing:
#       AUTH_USERNAME=<username>
#       AUTH_PASSWORD=<password>
#       AUTH_SECRET=<jwt secret key>
#
# Storage paths:
#   /var/lib/makersvault/data       — SQLite database
#   /storage/media/makervault/models — 3D model and file storage
#   /storage/media/makervault/import — read-only import mount
#
# Routing (via Traefik):
#   makersvault.jennex.dev/     → makersvault-web:5173
#   makersvault.jennex.dev/api  → makersvault-api:8000 (strips /api prefix)
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;
  domain = "makersvault.jennex.dev";
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/makersvault/data 0755 root root -"
    "d /storage/media/makervault/models 0755 root root -"
    "d /storage/media/makervault/import 0755 root root -"
  ];

  systemd.services.makersvault-env-setup = {
    description = "Build MakersVault environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["makersvault-api.service"];
    wantedBy = ["makersvault-api.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "makersvault-env-setup";
        text = ''
          {
            printf 'AUTH_USERNAME=%s\n' "$(cat /run/opnix/makersvault-username)"
            printf 'AUTH_PASSWORD=%s\n' "$(cat /run/opnix/makersvault-password)"
            printf 'AUTH_SECRET=%s\n'   "$(cat /run/opnix/makersvault-secret-key)"
          } > /run/opnix/makersvault-env
          chmod 600 /run/opnix/makersvault-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    networks.makersvault_network = {};

    containers.makersvault-api = {
      unitConfig = {
        After = ["opnix-secrets.service" "makersvault-env-setup.service"];
        Requires = ["opnix-secrets.service" "makersvault-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/shotgunwilly555/makersvault-api:latest";
        autoUpdate = "registry";
        networks = [networks.makersvault_network.ref networks.traefik_network.ref];
        environments = {
          PUID = "1000";
          PGID = "1000";
          FILE_STORAGE = "/app/storage";
          DB_URL = "sqlite:////app/data/app.db";
          PUBLIC_URL = "https://${domain}";
          CORS_ORIGINS = "https://${domain}";
          IMPORT_MOUNT_PATH = "/imports";
          IMPORT_MOUNT_ON_STARTUP = "true";
        };
        environmentFiles = ["/run/opnix/makersvault-env"];
        volumes = [
          "/var/lib/makersvault/data:/app/data"
          "/storage/media/makervault/models:/app/storage"
          "/storage/media/makervault/import:/imports:ro"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.makersvault-api-secure.entrypoints=https"
          "traefik.http.routers.makersvault-api-secure.rule=Host(`${domain}`) && PathPrefix(`/api`)"
          "traefik.http.routers.makersvault-api-secure.tls=true"
          "traefik.http.routers.makersvault-api-secure.middlewares=makersvault-stripapi@docker"
          "traefik.http.middlewares.makersvault-stripapi.stripprefix.prefixes=/api"
          "traefik.http.services.makersvault-api.loadbalancer.server.port=8000"
        ];
      };
    };

    containers.makersvault-web = {
      unitConfig = {
        After = ["makersvault-api.service"];
        Requires = ["makersvault-api.service"];
      };
      containerConfig = {
        image = "docker.io/shotgunwilly555/makersvault-web:latest";
        autoUpdate = "registry";
        networks = [networks.makersvault_network.ref networks.traefik_network.ref];
        environments = {
          PUID = "1000";
          PGID = "1000";
          PUBLIC_URL = "https://${domain}";
          VITE_API_URL = "https://${domain}/api";
          VITE_ALLOWED_HOSTS = domain;
          CORS_ORIGINS = "https://${domain}";
        };
        labels = [
          "homepage.group=Maker"
          "homepage.name=MakersVault"
          "homepage.icon=makersvault.png"
          "homepage.href=https://${domain}"
          "homepage.description=3D Print File Manager"
          "traefik.enable=true"
          "traefik.http.routers.makersvault.rule=Host(`${domain}`)"
          "traefik.http.routers.makersvault-secure.entrypoints=https"
          "traefik.http.routers.makersvault-secure.rule=Host(`${domain}`)"
          "traefik.http.routers.makersvault-secure.tls=true"
          "traefik.http.services.makersvault-web.loadbalancer.server.port=5173"
        ];
      };
    };
  };
}
