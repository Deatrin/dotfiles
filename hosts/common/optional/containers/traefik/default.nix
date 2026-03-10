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
          # TODO: set your Let's Encrypt email here
          email: "you@example.com"
          storage: /acme.json
          # Staging (comment out for production):
          # caServer: https://acme-staging-v02.api.letsencrypt.org/directory
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
      ];
    };
  };
}
