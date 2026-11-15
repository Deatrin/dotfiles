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

    # nd-lyrics plugin (https://github.com/J0R6IT0/navidrome-lyrics-plugin):
    # fetches synced lyrics from LRCLIB/lrcmux/etc. Needs Navidrome >= 0.63.
    # Enable + configure it in the web UI (Plugins); turn on "Write lyrics to
    # files" so the web player can show them (it can't show plugin lyrics).
    ndLyrics = pkgs.fetchurl {
      url = "https://github.com/J0R6IT0/navidrome-lyrics-plugin/releases/download/v9.2.0/nd-lyrics.ndp";
      hash = "sha256-UmK/7eNwAfoFpjyLvY856YbLrI3NiyV1R26PdRtK1cY=";
    };
    pluginsDir = "/var/lib/navidrome/plugins";
  in {
    options.dotfiles.navidrome.enable = lib.mkEnableOption "Navidrome music server";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = ["d ${pluginsDir} 0700 root root -"];

      systemd.services.navidrome-env-setup = {
        description = "Build Navidrome Last.fm env file and install plugins";
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

              # Pinned plugin from the Nix store. A version bump changes this
              # script, so the unit reruns on switch; Navidrome hot-reloads the
              # new file (ND_PLUGINS_AUTORELOAD).
              install -D -m 0644 ${ndLyrics} ${pluginsDir}/nd-lyrics.ndp
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
              ND_PLUGINS_FOLDER = "/plugins";
              ND_PLUGINS_AUTORELOAD = "true";
              # Sidecar/embedded lyrics first (Navidrome's default order), then
              # the nd-lyrics plugin as a fallback.
              ND_LYRICSPRIORITY = ".ttml,.yaml,.yml,.elrc,.lrc,.srt,.txt,embedded,nd-lyrics";
            };
            environmentFiles = ["/run/opnix/navidrome-env"];
            volumes = [
              "${volumes.navidrome.ref}:/data"
              # rw so nd-lyrics can write .lrc sidecars next to the tracks
              "/storage/media/music:/music"
              "${pluginsDir}:/plugins"
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
