{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
in {
  systemd.services.navidrome-env-setup = {
    description = "Build Navidrome OIDC environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["navidrome.service"];
    wantedBy = ["navidrome.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "navidrome-env-setup";
        text = ''
          {
            printf 'ND_OIDC_CLIENTID=%s\n'     "$(cat /run/opnix/navidrome-oidc-client-id)"
            printf 'ND_OIDC_CLIENTSECRET=%s\n' "$(cat /run/opnix/navidrome-oidc-client-secret)"
          } > /run/opnix/navidrome-oidc-env
          chmod 600 /run/opnix/navidrome-oidc-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    volumes.navidrome = {};

    containers.navidrome = {
      unitConfig = {
        After = ["opnix-secrets.service" "navidrome-env-setup.service"];
        Requires = ["opnix-secrets.service" "navidrome-env-setup.service"];
      };
      containerConfig = {
        image = "docker.io/deluan/navidrome:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = {
          ND_OIDC_ENABLED = "true";
          ND_OIDC_DISCOVERYURL = "https://pocket.jennex.dev/.well-known/openid-configuration";
        };
        environmentFiles = ["/run/opnix/navidrome-oidc-env"];
        volumes = [
          "${volumes.navidrome.ref}:/data"
          "/storage/media/music:/music:ro"
        ];
        labels = [
          "homepage.group=Media"
          "homepage.name=Navidrome"
          "homepage.icon=navidrome.png"
          "homepage.href=https://navi.jennex.dev"
          "homepage.description=Music Player"
          "traefik.enable=true"
          "traefik.http.routers.navi.rule=Host(`navi.jennex.dev`)"
          "traefik.http.routers.navi-secure.entrypoints=https"
          "traefik.http.routers.navi-secure.rule=Host(`navi.jennex.dev`)"
          "traefik.http.routers.navi-secure.tls=true"
          "traefik.http.services.navi.loadbalancer.server.port=4533"
        ];
      };
    };
  };
}
