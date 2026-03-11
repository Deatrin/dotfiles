# Forgejo — self-hosted Git service
#
# SSH port is configurable per-host via services.forgejo-quadlet.sshPort:
#   - testbed: default 2222
#   - nauvoo prod: set to 22 (system SSH is on 2222, port 22 is free)
#
# Data path is configurable per-host via services.forgejo-quadlet.dataPath:
#   - default: /var/lib/forgejo
#   - nauvoo prod: /ssdstorage/forgejo
#
# Runner setup (dind + runner containers):
#   TODO: Enable after first Forgejo startup:
#     1. Log in as admin → Settings → Actions → Runners → Create registration token
#     2. Add token to opnix: op://nix_secrets/forgejo/runner_token
#     3. Add runner_token secret to host secrets.nix
#     4. Uncomment dind and runner containers below
{
  config,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  options.services.forgejo-quadlet = {
    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = "Host port to expose Forgejo SSH on. Set to 22 on nauvoo (system SSH is on 2222).";
    };
    dataPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/forgejo";
      description = "Host base path for Forgejo data. Set to /ssdstorage/forgejo on nauvoo.";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${config.services.forgejo-quadlet.dataPath}/data   0755 root root -"
      "d ${config.services.forgejo-quadlet.dataPath}/runner 0755 root root -"
    ];

    virtualisation.quadlet = {
      networks.forgejo_network = {};

      volumes.forgejo-pgdata = {};

      # PostgreSQL — no password, internal network only
      containers.forgejo-db = {
        containerConfig = {
          image = "docker.io/library/postgres:17";
          autoUpdate = "registry";
          networks = [networks.forgejo_network.ref];
          environments = {
            POSTGRES_DB = "forgejo";
            POSTGRES_USER = "forgejo";
            POSTGRES_HOST_AUTH_METHOD = "trust";
          };
          volumes = ["${volumes.forgejo-pgdata.ref}:/var/lib/postgresql/data"];
        };
      };

      # Forgejo server
      containers.forgejo-server = {
        unitConfig = {
          After = ["forgejo-db.service"];
          Requires = ["forgejo-db.service"];
        };
        containerConfig = {
          image = "codeberg.org/forgejo/forgejo:13";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref networks.forgejo_network.ref];
          publishPorts = [
            "${toString config.services.forgejo-quadlet.sshPort}:22"
          ];
          environments = {
            TZ = "America/Los_Angeles";
            FORGEJO__database__DB_TYPE = "postgres";
            FORGEJO__database__HOST = "forgejo-db:5432";
            FORGEJO__database__NAME = "forgejo";
            FORGEJO__database__USER = "forgejo";
            FORGEJO__database__PASSWD = "";
            GNUPGHOME = "/data/gitea/home/.gnupg";
          };
          volumes = [
            "${config.services.forgejo-quadlet.dataPath}/data:/data"
          ];
          labels = [
            "homepage.group=Dev"
            "homepage.name=Forgejo"
            "homepage.icon=forgejo.png"
            "homepage.href=https://forgejo.jennex.dev"
            "homepage.description=Git"
            "traefik.enable=true"
            "traefik.http.routers.forgejo.rule=Host(`forgejo.jennex.dev`)"
            "traefik.http.routers.forgejo-secure.entrypoints=https"
            "traefik.http.routers.forgejo-secure.rule=Host(`forgejo.jennex.dev`)"
            "traefik.http.routers.forgejo-secure.tls=true"
            "traefik.http.services.forgejo.loadbalancer.server.port=3000"
          ];
        };
      };

      # TODO: Uncomment after first Forgejo startup and runner token is in opnix
      # Docker-in-Docker for CI runner
      # containers.forgejo-dind = {
      #   containerConfig = {
      #     image = "docker.io/library/docker:dind";
      #     autoUpdate = "registry";
      #     networks = [networks.forgejo_network.ref];
      #     addCapabilities = ["SYS_ADMIN"];
      #     securityLabelDisable = true;
      #     environments = {
      #       DOCKER_TLS_CERTDIR = "";
      #     };
      #     exec = ["dockerd" "-H" "tcp://0.0.0.0:2375" "--tls=false"];
      #   };
      # };

      # Forgejo runner
      # containers.forgejo-runner = {
      #   unitConfig = {
      #     After = ["opnix-secrets.service" "forgejo-dind.service" "forgejo-server.service"];
      #     Requires = ["opnix-secrets.service" "forgejo-dind.service" "forgejo-server.service"];
      #   };
      #   containerConfig = {
      #     image = "code.forgejo.org/forgejo/runner:12";
      #     autoUpdate = "registry";
      #     networks = [networks.forgejo_network.ref];
      #     user = "1000:1000";
      #     environments = {
      #       DOCKER_HOST = "tcp://forgejo-dind:2375";
      #     };
      #     environmentFiles = ["/run/opnix/forgejo-runner-env"];
      #     volumes = [
      #       "${config.services.forgejo-quadlet.dataPath}/runner:/data"
      #     ];
      #     exec = ["/bin/sh" "-c" "sleep 5; forgejo-runner daemon --config /data/config.yaml"];
      #   };
      # };
    };
  };
}
