# Pocket ID — OIDC identity provider
#
# Secrets required (via opnix):
#   /run/opnix/pocket-id-encryption-key  — base64 encryption key (openssl rand -base64 32)
#   /run/opnix/pocket-id-maxmind-key     — MaxMind license key for geolocation
{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/pocket-id 0755 root root -"
  ];

  systemd.services.pocket-id-env-setup = {
    description = "Build Pocket ID environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["pocket-id.service"];
    wantedBy = ["pocket-id.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "pocket-id-env-setup";
        text = ''
          {
            printf 'ENCRYPTION_KEY=%s\n'      "$(cat /run/opnix/pocket-id-encryption-key)"
            printf 'MAXMIND_LICENSE_KEY=%s\n' "$(cat /run/opnix/pocket-id-maxmind-key)"
          } > /run/opnix/pocket-id-env
          chmod 600 /run/opnix/pocket-id-env
        '';
      });
    };
  };

  virtualisation.quadlet.containers.pocket-id = {
    unitConfig = {
      After = ["opnix-secrets.service" "pocket-id-env-setup.service"];
      Requires = ["opnix-secrets.service" "pocket-id-env-setup.service"];
    };
    containerConfig = {
      image = "ghcr.io/pocket-id/pocket-id:v2";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        APP_URL = "https://pocket.jennex.dev";
        TRUST_PROXY = "true";
        PUID = "1000";
        PGID = "1000";
      };
      environmentFiles = ["/run/opnix/pocket-id-env"];
      volumes = ["/var/lib/pocket-id:/app/data"];
      labels = [
        "homepage.group=System"
        "homepage.name=Pocket ID"
        "homepage.icon=pocket-id.png"
        "homepage.href=https://pocket.jennex.dev"
        "homepage.description=OIDC Identity Provider"
        "traefik.enable=true"
        "traefik.http.routers.pocket-id.rule=Host(`pocket.jennex.dev`)"
        "traefik.http.routers.pocket-id-secure.entrypoints=https"
        "traefik.http.routers.pocket-id-secure.rule=Host(`pocket.jennex.dev`)"
        "traefik.http.routers.pocket-id-secure.tls=true"
        "traefik.http.services.pocket-id.loadbalancer.server.port=1411"
      ];
    };
  };
}
