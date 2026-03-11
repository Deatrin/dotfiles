# Traefik reverse proxy
#
# Secrets required (via opnix):
#   /run/opnix/cf-api-token        — Cloudflare API token for DNS challenge
#   /run/opnix/acme-email          — Let's Encrypt registration email
#   /run/opnix/traefik-dashboard-users — htpasswd file for dashboard basic auth
#
# First-run: ensure /var/lib/traefik/acme.json exists (handled by tmpfiles below)
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;

  traefikConfig = pkgs.writeText "traefik.yml" ''
    api:
      dashboard: true

    entryPoints:
      http:
        address: ":80"
        http:
          redirections:
            entryPoint:
              to: https
              scheme: https
      https:
        address: ":443"
        http:
          tls:
            certResolver: cloudflare
            domains:
              - main: "jennex.dev"
                sans:
                  - "*.jennex.dev"

    serversTransport:
      insecureSkipVerify: true

    providers:
      docker:
        endpoint: "unix:///var/run/docker.sock"
        exposedByDefault: false

    certificatesResolvers:
      cloudflare:
        acme:
          # Email injected via TRAEFIK_CERTIFICATESRESOLVERS_CLOUDFLARE_ACME_EMAIL in traefik-env
          storage: /acme.json
          dnsChallenge:
            provider: cloudflare
            resolvers:
              - "1.1.1.1:53"
              - "1.0.0.1:53"
  '';
in {
  # Ensure acme.json exists with correct permissions before container starts
  systemd.tmpfiles.rules = [
    "f /var/lib/traefik/acme.json 0600 root root -"
  ];

  # Build the Traefik env file from individual opnix secrets.
  # Runs after opnix has provisioned secrets, before the container starts.
  systemd.services.traefik-env-setup = {
    description = "Build Traefik environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["traefik.service"];
    wantedBy = ["traefik.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "traefik-env-setup";
        text = ''
          printf 'TRAEFIK_CERTIFICATESRESOLVERS_CLOUDFLARE_ACME_EMAIL=%s\n' \
            "$(cat /run/opnix/acme-email)" > /run/opnix/traefik-env
          chmod 600 /run/opnix/traefik-env
        '';
      });
    };
  };

  virtualisation.quadlet.containers.traefik = {
    unitConfig = {
      After = ["opnix-secrets.service" "traefik-env-setup.service"];
      Requires = ["opnix-secrets.service" "traefik-env-setup.service"];
    };
    containerConfig = {
      image = "docker.io/traefik:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      publishPorts = [
        "80:80"
        "443:443"
      ];
      # CF_DNS_API_TOKEN_FILE tells Traefik to read the token from a file
      environments = {
        CF_DNS_API_TOKEN_FILE = "/run/secrets/cf-api-token";
      };
      environmentFiles = ["/run/opnix/traefik-env"];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        # Podman socket (docker-compat API) for container discovery
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
        # Static config (Nix-managed, read-only)
        "${traefikConfig}:/traefik.yml:ro"
        # ACME cert storage (persistent, writable)
        "/var/lib/traefik/acme.json:/acme.json"
        # Cloudflare API token file
        "/run/opnix/cf-api-token:/run/secrets/cf-api-token:ro"
        # Dashboard basic auth htpasswd file
        "/run/opnix/traefik-dashboard-users:/run/secrets/dashboard-users:ro"
      ];
      noNewPrivileges = true;
      labels = [
        "traefik.enable=true"
        # HTTP → HTTPS redirect
        "traefik.http.routers.traefik.entrypoints=http"
        "traefik.http.routers.traefik.rule=Host(`traefik.jennex.dev`)"
        "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
        "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
        # Dashboard (wildcard cert via entrypoint default)
        "traefik.http.routers.traefik-secure.entrypoints=https"
        "traefik.http.routers.traefik-secure.rule=Host(`traefik.jennex.dev`)"
        "traefik.http.routers.traefik-secure.tls=true"
        "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
        "traefik.http.routers.traefik-secure.service=api@internal"
        # Dashboard basic auth
        "traefik.http.middlewares.traefik-auth.basicauth.usersfile=/run/secrets/dashboard-users"
      ];
    };
  };
}
