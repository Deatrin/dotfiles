# AudioMuse-AI — sonic analysis + similarity for the Navidrome library
# (https://github.com/NeptuneHub/AudioMuse-AI)
#
# Three containers: audiomuse-ai (Flask web UI/API), audiomuse-ai-worker
# (analysis/clustering queue) and audiomuse-db (Postgres 15 — the version
# AudioMuse is built for — trust auth on a private network, so no secrets).
# There's no music mount: the worker pulls audio through Navidrome's API.
#
# GPU: NVIDIA via CDI, same as ollama. Needs driver >= 580 (CUDA 13); falls
# back to CPU on out-of-memory.
#
# Version pin: the core image and the Navidrome plugin (audiomuseai, in
# navidrome.nix) must stay in step, so the image is pinned instead of
# autoUpdate. Bump both together; read the release notes first (major/minor
# releases can require a re-analysis).
#
# First run: open https://audiomuse.jennex.dev and finish the Setup Wizard
# right away (it's open until completed):
#   - media server: Navidrome, URL http://navidrome:4533, your Navidrome login
#   - set AudioMuse username/password and an API token
#   - then start an analysis
# In Navidrome > Plugins > AudioMuse-AI: URL http://audiomuse-ai:8000 + the token.
{self, ...}: {
  flake.modules.nixos.audiomuse = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.audiomuse;
    inherit (config.virtualisation.quadlet) networks volumes;

    image = "ghcr.io/neptunehub/audiomuse-ai:3.7.1-nvidia";

    commonEnv = {
      TZ = "America/Los_Angeles";
      POSTGRES_USER = "audiomuse";
      # Postgres uses trust auth; AudioMuse still builds a URL with a password.
      POSTGRES_PASSWORD = "unused-trust-auth";
      POSTGRES_DB = "audiomusedb";
      POSTGRES_HOST = "audiomuse-db";
      POSTGRES_PORT = "5432";
      TEMP_DIR = "/app/temp_audio";
    };

    dbDeps = {
      After = ["audiomuse-db.service"];
      Requires = ["audiomuse-db.service"];
    };
  in {
    options.dotfiles.audiomuse.enable = lib.mkEnableOption "AudioMuse-AI sonic analysis for Navidrome";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet = {
        networks.audiomuse_network = {};

        volumes = {
          audiomuse-pgdata = {};
          audiomuse-temp-flask = {};
          audiomuse-temp-worker = {};
          audiomuse-plugins-flask = {};
          audiomuse-plugins-worker = {};
        };

        containers.audiomuse-db = {
          containerConfig = {
            image = "docker.io/library/postgres:15-alpine";
            autoUpdate = "registry";
            networks = [networks.audiomuse_network.ref];
            environments = {
              TZ = "America/Los_Angeles";
              POSTGRES_USER = "audiomuse";
              POSTGRES_DB = "audiomusedb";
              POSTGRES_HOST_AUTH_METHOD = "trust";
            };
            volumes = ["${volumes.audiomuse-pgdata.ref}:/var/lib/postgresql/data"];
          };
        };

        # Web UI + API (the Navidrome plugin talks to this one).
        containers.audiomuse-ai = {
          unitConfig = dbDeps;
          containerConfig = {
            inherit image;
            networks = [
              networks.traefik_network.ref
              networks.audiomuse_network.ref
            ];
            environments = commonEnv // {SERVICE_TYPE = "flask";};
            volumes = [
              "${volumes.audiomuse-temp-flask.ref}:/app/temp_audio"
              "${volumes.audiomuse-plugins-flask.ref}:/app/plugin/installed"
            ];
            podmanArgs = ["--device=nvidia.com/gpu=all"];
            labels = self.lib.webLabels {
              host = "audiomuse.jennex.dev";
              router = "audiomuse";
              port = 8000;
              homepage = {
                group = "Media";
                name = "AudioMuse-AI";
                icon = "audiomuse-ai.png";
                description = "Sonic Analysis";
              };
            };
          };
        };

        # Analysis/clustering queue. On traefik_network too, to reach Navidrome.
        containers.audiomuse-ai-worker = {
          unitConfig = dbDeps;
          containerConfig = {
            inherit image;
            networks = [
              networks.traefik_network.ref
              networks.audiomuse_network.ref
            ];
            environments =
              commonEnv
              // {
                SERVICE_TYPE = "worker";
                USE_GPU_CLUSTERING = "true";
              };
            volumes = [
              "${volumes.audiomuse-temp-worker.ref}:/app/temp_audio"
              "${volumes.audiomuse-plugins-worker.ref}:/app/plugin/installed"
            ];
            podmanArgs = ["--device=nvidia.com/gpu=all"];
          };
        };
      };
    };
  };
}
