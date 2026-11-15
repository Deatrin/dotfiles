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

    # Navidrome plugins, installed as <name>.ndp. The name is what
    # ND_AGENTS / ND_LYRICSPRIORITY refer to. Each one still has to be enabled
    # (and configured) in the web UI under Plugins.
    ghRelease = repo: tag: file: hash:
      pkgs.fetchurl {
        url = "https://github.com/${repo}/releases/download/${tag}/${file}";
        inherit hash;
      };
    plugins =
      {
        # Synced lyrics from LRCLIB/lrcmux/etc. Turn on "Write lyrics to files"
        # so the web player can show them (it can't show plugin lyrics).
        nd-lyrics =
          ghRelease "J0R6IT0/navidrome-lyrics-plugin" "v9.2.0" "nd-lyrics.ndp"
          "sha256-UmK/7eNwAfoFpjyLvY856YbLrI3NiyV1R26PdRtK1cY=";
        # Listening-aware playlists (time-of-day, Rediscover, ...). The 0.64
        # build reads Navidrome's play history; it must be named navibeat-mixes.
        navibeat-mixes =
          ghRelease "nenadjokic/navibeat-mixes" "v0.9.30" "navibeat-mixes-navidrome-0.64.ndp"
          "sha256-yetg4PlQ/Im1tZZT4pKADL9nq72j1jqKg3bU8g2fGeU=";
        # Artist bios/images/similar artists from Apple Music (metadata agent).
        apple-music =
          ghRelease "navidrome/apple-music-plugin" "v0.2.0" "apple-music.ndp"
          "sha256-NoJ1HnLKpcxGs/ercN5w6gJvCjikf3gLLStJIu0K0VQ=";
        # ListenBrainz daily/weekly playlists. Per-user config in the UI; Daily
        # Jams also needs the ListenBrainz account to follow "troi-bot".
        listenbrainz-daily-playlist =
          ghRelease "kgarner7/navidrome-listenbrainz-daily-playlist" "v6.0.0" "listenbrainz-daily-playlist.ndp"
          "sha256-uYNqX0MjO/o/ePokVqwJjLgpBSvv659UfgOBCkHgGEY=";
        # Album art from MusicBrainz/Cover Art Archive (metadata agent, last in
        # ND_AGENTS as a fallback). Built in the 0.63 era; if it fails to load
        # on a newer Navidrome, check `podman logs navidrome | grep coverart`.
        coverartarchive =
          ghRelease "sunsetroute1/navidrome-coverartarchive-plugin" "v1.0.0" "coverartarchive.ndp"
          "sha256-Ow7JBVzngl6+z3DxKeaar8LT8TmDds56fTkOMecgRss=";
      }
      // lib.optionalAttrs audiomuse {
        # Sonic similarity for Instant Mix/Radio, backed by the AudioMuse-AI
        # stack (audiomuse.nix). Pinned in step with its core image there.
        audiomuseai =
          ghRelease "NeptuneHub/AudioMuse-AI-NV-plugin" "v12" "audiomuseai.ndp"
          "sha256-2oUSxPOy06WP6mEeOrNsetU+fdx8nZsWIxEBrpiAntg=";
      };
    audiomuse = config.dotfiles.audiomuse.enable or false;
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
            runtimeInputs = [pkgs.coreutils pkgs.diffutils];
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

              # Pinned plugins from the Nix store. Any change to the set changes
              # this script, so the unit reruns on switch; Navidrome hot-reloads
              # (ND_PLUGINS_AUTORELOAD). Only changed files are rewritten and
              # only plugins dropped from the set are deleted, so unchanged
              # plugins are never unloaded.
              mkdir -p ${pluginsDir}
              install_plugin() {
                cmp -s "$1" "$2" || install -m 0644 "$1" "$2"
              }
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList
                (name: src: "install_plugin ${src} ${pluginsDir}/${name}.ndp")
                plugins)}
              for f in ${pluginsDir}/*.ndp; do
                case "$(basename "$f" .ndp)" in
                  ${lib.concatStringsSep "|" (lib.attrNames plugins)}) ;;
                  *) rm -f "$f" ;;
                esac
              done
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
              # Metadata agents, tried in order. Replaces the default
              # "deezer,lastfm,listenbrainz", so those stay listed.
              # audiomuseai must come first: Navidrome uses the first agent
              # with sonic similarity for Instant Mix.
              ND_AGENTS = lib.concatStringsSep "," (
                lib.optional audiomuse "audiomuseai"
                ++ ["apple-music" "deezer" "lastfm" "listenbrainz" "coverartarchive"]
              );
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
