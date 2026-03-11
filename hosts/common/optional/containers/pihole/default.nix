# Pi-hole DNS + ad blocking
#
# Secrets required (via opnix):
#   /run/opnix/pihole-env  — env file containing:
#       FTLCONF_webserver_api_password=<password>
#
# The wildcard dnsmasq config is baked in via Nix — no manual config needed.
# DNS listens on the host's primary IP (set per-host via dnsListenIP option).
# For Tailscale remote access, testbed advertises subnet routes so Tailscale
# clients can reach 10.1.40.200:53 directly as a nameserver.
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;

  # Wildcard local DNS — all *.jennex.dev resolves to this host's IP
  dnsmasqConfig = pkgs.writeText "02-deatrin-local.conf" ''
    address=/.jennex.dev/${config.services.pihole-quadlet.dnsListenIP}
  '';

  # Per-host DNS overrides — specific hostnames resolved to their own IPs
  # (bypasses Traefik for services that can't be proxied, e.g. iDRAC)
  dnsOverridesConfig = pkgs.writeText "03-deatrin-overrides.conf" (
    lib.concatMapStrings (entry: "address=/${entry.hostname}/${entry.ip}\n")
      config.services.pihole-quadlet.dnsOverrides
  );
in {
  options.services.pihole-quadlet.dnsListenIP = lib.mkOption {
    type = lib.types.str;
    description = "IP address Pi-hole binds DNS to, and used for local DNS wildcard.";
  };

  options.services.pihole-quadlet.dnsOverrides = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        hostname = lib.mkOption { type = lib.types.str; };
        ip = lib.mkOption { type = lib.types.str; };
      };
    });
    default = [];
    description = "Specific hostname → IP overrides, bypassing the wildcard (e.g. iDRAC).";
  };

  config = {
    virtualisation.quadlet = {
      volumes."etc-pihole" = {};

      containers.pihole = {
        unitConfig = {
          After = ["opnix-secrets.service"];
          Requires = ["opnix-secrets.service"];
        };
        containerConfig = {
          image = "docker.io/pihole/pihole:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          publishPorts = [
            "${config.services.pihole-quadlet.dnsListenIP}:53:53/tcp"
            "${config.services.pihole-quadlet.dnsListenIP}:53:53/udp"
          ];
          environments = {
            TZ = "America/Los_Angeles";
            FTLCONF_dns_listeningMode = "all";
            # Enable custom dnsmasq.d config directory
            FTLCONF_misc_etc_dnsmasq_d = "true";
          };
          environmentFiles = ["/run/opnix/pihole-env"];
          volumes = [
            "${volumes."etc-pihole".ref}:/etc/pihole"
            # Wildcard local DNS config (Nix-managed)
            "${dnsmasqConfig}:/etc/dnsmasq.d/02-deatrin-local.conf:ro"
            # Per-host DNS overrides (Nix-managed)
            "${dnsOverridesConfig}:/etc/dnsmasq.d/03-deatrin-overrides.conf:ro"
          ];
          addCapabilities = ["NET_ADMIN" "SYS_TIME" "SYS_NICE"];
          labels = [
            "traefik.enable=true"
            "traefik.http.routers.pihole.rule=Host(`pihole.jennex.dev`)"
            "traefik.http.routers.pihole-secure.entrypoints=https"
            "traefik.http.routers.pihole-secure.rule=Host(`pihole.jennex.dev`)"
            "traefik.http.routers.pihole-secure.tls=true"
            "traefik.http.services.pihole.loadbalancer.server.port=80"
          ];
        };
      };
    };
  };
}
