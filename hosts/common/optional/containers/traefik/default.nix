# Traefik reverse proxy
#
# Secrets required (via opnix):
#   /run/opnix/cf-api-token        — Cloudflare API token for DNS challenge
#   /run/opnix/acme-email          — Let's Encrypt registration email
#   /run/opnix/traefik-dashboard-users — htpasswd file for dashboard basic auth
#
# First-run: ensure /var/lib/traefik/acme.json exists (handled by tmpfiles below)
#
# External services: set services.traefik-quadlet.externalServices in your host config
# to proxy non-container services by hostname, e.g.:
#   services.traefik-quadlet.externalServices = [
#     { name = "idrac-proxmox"; hostname = "idrac-proxmox.jennex.dev"; url = "https://10.1.20.10"; }
#   ];
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;
  externalServices = config.services.traefik-quadlet.externalServices;

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
      file:
        filename: /etc/traefik/external.yml
        watch: true

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

  # Generate dynamic config YAML for external services, mounted directly from Nix store
  # (avoids symlink issues with environment.etc inside containers)
  mkExternalServicesYaml = svcs:
    "http:\n"
    + "  routers:\n"
    + lib.concatMapStrings (svc:
      "    ${svc.name}:\n"
      + "      rule: \"Host(`${svc.hostname}`)\"\n"
      + "      entrypoints:\n"
      + "        - https\n"
      + "      tls: {}\n"
      + "      service: ${svc.name}\n") svcs
    + "  services:\n"
    + lib.concatMapStrings (svc:
      "    ${svc.name}:\n"
      + "      loadBalancer:\n"
      + "        servers:\n"
      + "          - url: \"${svc.url}\"\n") svcs;

  # Always generate the file — empty when no external services, avoids missing file error
  externalServicesFile = pkgs.writeText "traefik-external.yml" (
    if externalServices == []
    then "# No external services configured\n"
    else mkExternalServicesYaml externalServices
  );
in {
  options.services.traefik-quadlet.externalServices = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Unique name for the router/service (no spaces).";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "Hostname to match, e.g. idrac-proxmox.jennex.dev";
        };
        url = lib.mkOption {
          type = lib.types.str;
          description = "Backend URL, e.g. https://10.1.20.10";
        };
      };
    });
    default = [];
    description = "External (non-container) services to proxy through Traefik.";
  };

  config = {
    # Ensure acme.json exists with correct permissions before container starts
    systemd.tmpfiles.rules = [
      "f /var/lib/traefik/acme.json 0600 root root -"
    ];

    # Build the Traefik env file from individual opnix secrets.
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
          # External services dynamic config (Nix store file, avoids symlink issues)
          "${externalServicesFile}:/etc/traefik/external.yml:ro"
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
  };
}
