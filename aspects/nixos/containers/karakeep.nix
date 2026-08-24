# Karakeep — self-hosted bookmark manager (formerly Hoarder)
#
# Three containers: karakeep (web+worker), karakeep-chrome (headless browser
# for crawling/screenshots), karakeep-meilisearch (full-text search index).
# Storage is SQLite (DATA_DIR), not Postgres.
#
# Secrets required (via op-connect-secrets, see hosts/nixos/nauvoo/secrets.nix):
#   /run/opnix/karakeep-env  — env file containing:
#       NEXTAUTH_SECRET=<random string, e.g. openssl rand -base64 32>
#       MEILI_MASTER_KEY=<random string, e.g. openssl rand -base64 32>
#       OAUTH_CLIENT_ID=<Pocket ID OIDC client ID>
#       OAUTH_CLIENT_SECRET=<Pocket ID OIDC client secret>
#
# Pocket ID setup:
#   OIDC client callback URL: https://karakeep.jennex.dev/api/auth/callback/custom
#
# AI tagging: points at nauvoo's existing Ollama container (see ollama.nix) —
# joins ollama_network, so dotfiles.ollama.enable must also be true. Uses
# gemma4:e4b (already pulled, chat model) for text and moondream (small
# vision model) for images — pull moondream before switching:
#   sudo podman exec -it ollama ollama pull moondream
{
  flake.modules.nixos.karakeep = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.dotfiles.karakeep;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.karakeep.enable = lib.mkEnableOption "Karakeep bookmark manager";

    config = lib.mkIf cfg.enable {
      systemd.services.karakeep-env-setup = {
        description = "Build Karakeep environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["karakeep.service" "karakeep-meilisearch.service"];
        wantedBy = ["karakeep.service" "karakeep-meilisearch.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "karakeep-env-setup";
            text = ''
              {
                printf 'NEXTAUTH_SECRET=%s\n'    "$(cat /run/opnix/karakeep-nextauth-secret)"
                printf 'MEILI_MASTER_KEY=%s\n'   "$(cat /run/opnix/karakeep-meili-master-key)"
                printf 'OAUTH_CLIENT_ID=%s\n'     "$(cat /run/opnix/karakeep-oidc-client-id)"
                printf 'OAUTH_CLIENT_SECRET=%s\n' "$(cat /run/opnix/karakeep-oidc-client-secret)"
              } > /run/opnix/karakeep-env
              chmod 600 /run/opnix/karakeep-env
            '';
          });
        };
      };

      virtualisation.quadlet = {
        networks.karakeep_network = {};

        volumes = {
          karakeep-data = {};
          karakeep-meilisearch = {};
        };

        containers.karakeep-chrome = {
          containerConfig = {
            image = "ghcr.io/karakeep-app/karakeep-chrome:release";
            autoUpdate = "registry";
            networks = [networks.karakeep_network.ref];
            exec = "--no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --hide-scrollbars --disable-blink-features=AutomationControlled --window-size=1440,900";
          };
        };

        containers.karakeep-meilisearch = {
          unitConfig = {
            After = ["opnix-secrets.service" "karakeep-env-setup.service"];
            Requires = ["opnix-secrets.service" "karakeep-env-setup.service"];
          };
          containerConfig = {
            image = "docker.io/getmeili/meilisearch:v1.41.0";
            autoUpdate = "registry";
            networks = [networks.karakeep_network.ref];
            environments = {
              MEILI_NO_ANALYTICS = "true";
            };
            environmentFiles = ["/run/opnix/karakeep-env"];
            volumes = ["${volumes.karakeep-meilisearch.ref}:/meili_data"];
          };
        };

        containers.karakeep = {
          unitConfig = {
            After = [
              "opnix-secrets.service"
              "karakeep-env-setup.service"
              "karakeep-chrome.service"
              "karakeep-meilisearch.service"
              "ollama.service"
            ];
            Requires = [
              "opnix-secrets.service"
              "karakeep-env-setup.service"
              "karakeep-chrome.service"
              "karakeep-meilisearch.service"
              "ollama.service"
            ];
          };
          containerConfig = {
            image = "ghcr.io/karakeep-app/karakeep:release";
            autoUpdate = "registry";
            networks = [
              networks.traefik_network.ref
              networks.karakeep_network.ref
              networks.ollama_network.ref
            ];
            environments = {
              DATA_DIR = "/data";
              NEXTAUTH_URL = "https://karakeep.jennex.dev";
              MEILI_ADDR = "http://karakeep-meilisearch:7700";
              BROWSER_WEB_URL = "http://karakeep-chrome:9222";
              OAUTH_WELLKNOWN_URL = "https://pocket.jennex.dev/.well-known/openid-configuration";
              OAUTH_PROVIDER_NAME = "Pocket ID";
              OLLAMA_BASE_URL = "http://ollama:11434";
              # Text tagging reuses the model already pulled for chat/Open WebUI.
              # Image tagging uses moondream — small vision model, low VRAM
              # overhead alongside gemma4:e4b on the 2080's 8GB.
              INFERENCE_TEXT_MODEL = "gemma4:e4b";
              INFERENCE_IMAGE_MODEL = "moondream";
            };
            environmentFiles = ["/run/opnix/karakeep-env"];
            volumes = ["${volumes.karakeep-data.ref}:/data"];
            labels = [
              "homepage.group=Home"
              "homepage.name=Karakeep"
              "homepage.icon=karakeep.png"
              "homepage.href=https://karakeep.jennex.dev"
              "homepage.description=Bookmark Manager"
              "traefik.enable=true"
              "traefik.http.routers.karakeep.rule=Host(`karakeep.jennex.dev`)"
              "traefik.http.routers.karakeep-secure.entrypoints=https"
              "traefik.http.routers.karakeep-secure.rule=Host(`karakeep.jennex.dev`)"
              "traefik.http.routers.karakeep-secure.tls=true"
              "traefik.http.services.karakeep.loadbalancer.server.port=3000"
            ];
          };
        };
      };
    };
  };
}
