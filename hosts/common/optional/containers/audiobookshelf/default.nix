{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/audiobookshelf/config 0755 root root -"
    "d /var/lib/audiobookshelf/metadata 0755 root root -"
  ];

  systemd.services.audiobookshelf-env-setup = {
    description = "Build Audiobookshelf OIDC environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["audiobookshelf.service"];
    wantedBy = ["audiobookshelf.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "audiobookshelf-env-setup";
        text = ''
          {
            printf 'OIDC_CLIENT_ID=%s\n'     "$(cat /run/opnix/audiobookshelf-oidc-client-id)"
            printf 'OIDC_CLIENT_SECRET=%s\n' "$(cat /run/opnix/audiobookshelf-oidc-client-secret)"
          } > /run/opnix/audiobookshelf-oidc-env
          chmod 600 /run/opnix/audiobookshelf-oidc-env
        '';
      });
    };
  };

  virtualisation.quadlet.containers.audiobookshelf = {
    unitConfig = {
      After = ["opnix-secrets.service" "audiobookshelf-env-setup.service"];
      Requires = ["opnix-secrets.service" "audiobookshelf-env-setup.service"];
    };
    containerConfig = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        TZ = "America/Los_Angeles";
        OIDC_ISSUER = "https://pocket.jennex.dev";
        OIDC_CLIENT_NAME = "Pocket ID";
        OIDC_JWKS_URL = "https://pocket.jennex.dev/api/oidc/jwks";
        OIDC_USER_INFO_URL = "https://pocket.jennex.dev/api/oidc/userinfo";
        OIDC_TOKEN_URL = "https://pocket.jennex.dev/api/oidc/token";
        OIDC_AUTH_URL = "https://pocket.jennex.dev/authorize";
        OIDC_LOGOUT_URL = "https://pocket.jennex.dev/api/oidc/logout";
      };
      environmentFiles = [
        "/run/opnix/audiobookshelf-oidc-env"
      ];
      volumes = [
        "/storage/media/audiobooks:/audiobooks"
        "/storage/media/audiobooks:/podcasts"
        "/var/lib/audiobookshelf/config:/config"
        "/var/lib/audiobookshelf/metadata:/metadata"
      ];
      labels = [
        "homepage.group=Media"
        "homepage.name=Audiobookshelf"
        "homepage.icon=audiobookshelf.png"
        "homepage.href=https://audiobookshelf.jennex.dev"
        "homepage.description=Audiobook player"
        "traefik.enable=true"
        "traefik.http.routers.audiobookshelf.rule=Host(`audiobookshelf.jennex.dev`)"
        "traefik.http.routers.audiobookshelf-secure.entrypoints=https"
        "traefik.http.routers.audiobookshelf-secure.rule=Host(`audiobookshelf.jennex.dev`)"
        "traefik.http.routers.audiobookshelf-secure.tls=true"
        "traefik.http.services.audiobookshelf.loadbalancer.server.port=80"
      ];
    };
  };
}
