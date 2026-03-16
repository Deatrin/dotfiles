# Traefik Forward Auth — OIDC authentication middleware via Pocket ID
#
# Secrets required (via opnix):
#   /run/opnix/traefik-forward-auth-client-id     — OIDC client ID from Pocket ID
#   /run/opnix/traefik-forward-auth-client-secret — OIDC client secret from Pocket ID
#   /run/opnix/traefik-forward-auth-cookie-secret — Random cookie signing secret (openssl rand -hex 16)
#
# Pocket ID setup:
#   OIDC client callback URL: https://auth.jennex.dev/_oauth
#
# Usage: add to any Traefik-routed container router:
#   "traefik.http.routers.<name>-secure.middlewares=forward-auth"
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.services.traefik-forward-auth-env-setup = {
    description = "Build Traefik Forward Auth environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["traefik-forward-auth.service"];
    wantedBy = ["traefik-forward-auth.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "traefik-forward-auth-env-setup";
        text = ''
          {
            printf 'PROVIDERS_OIDC_CLIENT_ID=%s\n'     "$(cat /run/opnix/traefik-forward-auth-client-id)"
            printf 'PROVIDERS_OIDC_CLIENT_SECRET=%s\n' "$(cat /run/opnix/traefik-forward-auth-client-secret)"
            printf 'SECRET=%s\n'                        "$(cat /run/opnix/traefik-forward-auth-cookie-secret)"
          } > /run/opnix/traefik-forward-auth-env
          chmod 600 /run/opnix/traefik-forward-auth-env
        '';
      });
    };
  };

  virtualisation.quadlet.containers.traefik-forward-auth = {
    unitConfig = {
      After = ["opnix-secrets.service" "traefik-forward-auth-env-setup.service"];
      Requires = ["opnix-secrets.service" "traefik-forward-auth-env-setup.service"];
    };
    containerConfig = {
      image = "docker.io/thomseddon/traefik-forward-auth:2";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        DEFAULT_PROVIDER = "oidc";
        PROVIDERS_OIDC_ISSUER_URL = "https://pocket.jennex.dev";
        AUTH_HOST = "auth.jennex.dev";
        COOKIE_DOMAIN = "jennex.dev";
        LOG_LEVEL = "trace";
      };
      environmentFiles = ["/run/opnix/traefik-forward-auth-env"];
      labels = [
        "traefik.enable=true"
        # Route for the OIDC callback
        "traefik.http.routers.forward-auth-secure.entrypoints=https"
        "traefik.http.routers.forward-auth-secure.rule=Host(`auth.jennex.dev`)"
        "traefik.http.routers.forward-auth-secure.tls=true"
        "traefik.http.routers.forward-auth-secure.middlewares=forward-auth"
        "traefik.http.services.forward-auth.loadbalancer.server.port=4181"
        # Shared forward-auth middleware — usable by any Traefik router
        "traefik.http.middlewares.forward-auth.forwardauth.address=http://traefik-forward-auth:4181"
        "traefik.http.middlewares.forward-auth.forwardauth.authResponseHeaders=X-Forwarded-User"
        "traefik.http.middlewares.forward-auth.forwardauth.trustForwardHeader=true"
      ];
    };
  };
}
