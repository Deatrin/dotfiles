# Open WebUI — web interface for Ollama
#
# Secrets required (via op-connect-secrets):
#   /run/opnix/open-webui-oidc-client-id     — Pocket ID OIDC client ID
#   /run/opnix/open-webui-oidc-client-secret — Pocket ID OIDC client secret
#   /run/opnix/open-webui-secret-key         — Session signing key (openssl rand -hex 32)
#
# Pocket ID setup:
#   OIDC client callback URL: https://ai.jennex.dev/oauth/oidc/callback
#
# Routing:
#   ai.jennex.dev → Open WebUI (native Pocket ID OIDC, port 8080)
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  systemd.services.open-webui-env-setup = {
    description = "Build Open WebUI environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["open-webui.service"];
    wantedBy = ["open-webui.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "open-webui-env-setup";
        text = ''
          {
            printf 'OAUTH_CLIENT_ID=%s\n'     "$(cat /run/opnix/open-webui-oidc-client-id)"
            printf 'OAUTH_CLIENT_SECRET=%s\n' "$(cat /run/opnix/open-webui-oidc-client-secret)"
            printf 'WEBUI_SECRET_KEY=%s\n'    "$(cat /run/opnix/open-webui-secret-key)"
          } > /run/opnix/open-webui-env
          chmod 600 /run/opnix/open-webui-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    volumes.open-webui = {};

    containers.open-webui = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "open-webui-env-setup.service"
          "ollama.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "open-webui-env-setup.service"
          "ollama.service"
        ];
      };
      containerConfig = {
        image = "ghcr.io/open-webui/open-webui:main";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref networks.ollama_network.ref];
        environments = {
          OLLAMA_BASE_URL = "http://ollama:11434";
          OPENID_PROVIDER_URL = "https://pocket.jennex.dev/.well-known/openid-configuration";
          OAUTH_REDIRECT_URI = "https://ai.jennex.dev/oauth/oidc/callback";
          OAUTH_PROVIDER_NAME = "Pocket ID";
          ENABLE_OAUTH_SIGNUP = "true";
          ENABLE_LOGIN_FORM = "false";
          WEBUI_AUTH = "true";
        };
        environmentFiles = ["/run/opnix/open-webui-env"];
        volumes = ["${volumes.open-webui.ref}:/app/backend/data"];
        labels = [
          "homepage.group=Dev & Games"
          "homepage.name=Open WebUI"
          "homepage.icon=open-webui.png"
          "homepage.href=https://ai.jennex.dev"
          "homepage.description=LLM Chat Interface"
          "traefik.enable=true"
          "traefik.http.routers.open-webui.rule=Host(`ai.jennex.dev`)"
          "traefik.http.routers.open-webui-secure.entrypoints=https"
          "traefik.http.routers.open-webui-secure.rule=Host(`ai.jennex.dev`)"
          "traefik.http.routers.open-webui-secure.tls=true"
          "traefik.http.services.open-webui.loadbalancer.server.port=8080"
        ];
      };
    };
  };
}
