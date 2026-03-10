# Pi-hole DNS + ad blocking
#
# Secrets required (via opnix):
#   /run/opnix/pihole-env  — env file containing:
#       FTLCONF_webserver_api_password=<password>
#
# The wildcard dnsmasq config is baked in via Nix — no manual config needed.
# DNS listens on the host's primary IP (set per-host via dnsListenIP option).
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;

  # Wildcard local DNS — all *.deatrin.dev resolves to this host's IP
  dnsmasqConfig = pkgs.writeText "02-deatrin-local.conf" ''
    address=/.deatrin.dev/${config.services.pihole-quadlet.dnsListenIP}
  '';
in {
  options.services.pihole-quadlet.dnsListenIP = lib.mkOption {
    type = lib.types.str;
    description = "IP address Pi-hole binds DNS to, and used for local DNS wildcard.";
  };

  config = {
    virtualisation.quadlet = {
      volumes."etc-pihole" = {};

      containers.pihole = {
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
          ];
          addCapabilities = ["NET_ADMIN" "SYS_TIME" "SYS_NICE"];
          labels = [
            "traefik.enable=true"
            "traefik.http.routers.pihole.rule=Host(`pihole.deatrin.dev`)"
            "traefik.http.routers.pihole-secure.entrypoints=https"
            "traefik.http.routers.pihole-secure.rule=Host(`pihole.deatrin.dev`)"
            "traefik.http.routers.pihole-secure.tls=true"
            "traefik.http.routers.pihole-secure.tls.certresolver=cloudflare"
            "traefik.http.services.pihole.loadbalancer.server.port=80"
          ];
        };
      };
    };
  };
}
