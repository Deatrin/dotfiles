# Secrets required (via op-connect-secrets, hosts/nixos/nauvoo/secrets.nix):
#   op://nix_secrets/navidrome/lastfm_api_key  -> navidromeLastfmApiKey
#   op://nix_secrets/navidrome/lastfm_secret   -> navidromeLastfmSecret
{self, ...}: {
  flake.modules.nixos.navidrome = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.navidrome;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.navidrome.enable = lib.mkEnableOption "Navidrome music server";

    config = lib.mkIf cfg.enable {
      systemd.services.navidrome-env-setup = {
        description = "Build Navidrome Last.fm environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["navidrome.service"];
        wantedBy = ["navidrome.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "navidrome-env-setup";
            # Plain assignments so a missing secret aborts (set -e) instead of
            # silently writing an empty value, which printf "$(cat ...)" would.
            text = ''
              api_key=$(cat /run/opnix/navidrome-lastfm-api-key)
              secret=$(cat /run/opnix/navidrome-lastfm-secret)
              umask 077
              {
                printf 'ND_LASTFM_APIKEY=%s\n' "$api_key"
                printf 'ND_LASTFM_SECRET=%s\n' "$secret"
              } > /run/opnix/navidrome-env
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
              ND_LASTFM_ENABLED = "true";
            };
            environmentFiles = ["/run/opnix/navidrome-env"];
            volumes = [
              "${volumes.navidrome.ref}:/data"
              "/storage/media/music:/music:ro"
            ];
            labels = self.lib.webLabels {
              host = "navi.jennex.dev";
              router = "navi";
              port = 4533;
              homepage = {
                group = "Media";
                name = "Navidrome";
                icon = "navidrome.png";
                description = "Music Player";
              };
            };
          };
        };
      };
    };
  };
}
