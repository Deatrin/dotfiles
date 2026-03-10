# Traefik reverse proxy
#
# Secrets required (via opnix):
#   /run/opnix/cf-api-token        — Cloudflare API token for DNS challenge
#   /run/opnix/traefik-env         — env file containing:
#       TRAEFIK_DASHBOARD_CREDENTIALS=<htpasswd-format user:hash>
#
# First-run: ensure /var/lib/traefik/acme.json exists (handled by tmpfiles below)
# Tailscale: Traefik reads the host tailscaled socket to issue *.ts.net certs
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
          # Switch to prod when ready: https://acme-v02.api.letsencrypt.org/directory
          caServer: https://acme-staging-v02.api.letsencrypt.org/directory
          dnsChallenge:
            provider: cloudflare
            resolvers:
              - "1.1.1.1:53"
              - "1.0.0.1:53"
      tailscale:
        tailscale: {}
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
          chmod 600 /run/traefik-env
        '';
      });
    };
  };

  virtualisation.quadlet.containers.traefik = {
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
        # Tailscale daemon socket for TS cert resolver
        "/var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock"
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
        "traefik.http.routers.traefik.rule=Host(`traefik.deatrin.dev`)"
        "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
        "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
        # Dashboard (public, LE cert)
        "traefik.http.routers.traefik-secure.entrypoints=https"
        "traefik.http.routers.traefik-secure.rule=Host(`traefik.deatrin.dev`)"
        "traefik.http.routers.traefik-secure.tls=true"
        "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
        "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
        "traefik.http.routers.traefik-secure.service=api@internal"
        # Dashboard basic auth (credentials from TRAEFIK_DASHBOARD_CREDENTIALS in traefik-env)
        "traefik.http.middlewares.traefik-auth.basicauth.usersfile=/run/secrets/dashboard-users"
        # Dashboard (Tailscale)
        "traefik.http.routers.traefik-ts.entrypoints=https"
        "traefik.http.routers.traefik-ts.rule=Host(`traefik.tail64718.ts.net`)"
        "traefik.http.routers.traefik-ts.tls=true"
        "traefik.http.routers.traefik-ts.tls.certresolver=tailscale"
        "traefik.http.routers.traefik-ts.middlewares=traefik-auth"
        "traefik.http.routers.traefik-ts.service=api@internal"
      ];
    };
  };
}
