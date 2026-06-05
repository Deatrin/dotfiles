# Arr-stack — media management suite
#
# Secrets required (via op-connect-secrets):
#   /run/opnix/recyclarr-sonarr-api-key  — Sonarr API key
#   /run/opnix/recyclarr-radarr-api-key  — Radarr API key
#   1Password: op://nix_secrets/recyclarr/{sonarr_api_key,radarr_api_key}
#
# Media paths (/storage/media/*) are commented out — only available on nauvoo.
# All arr services share the sabnzbd downloads path for cross-service hardlinking.
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;

  commonEnv = {
    PUID = "1000";
    PGID = "1000";
    TZ = "America/Los_Angeles";
  };

  recyclarrConfig = pkgs.writeText "recyclarr.yml" ''
    sonarr:
      main:
        base_url: http://sonarr:8989
        api_key: !env_var SONARR_API_KEY
        quality_definition:
          type: series
        quality_profiles:
          - name: WEB-1080p
            score_set: default
          - name: WEB-2160p
            score_set: default

    radarr:
      main:
        base_url: http://radarr:7878
        api_key: !env_var RADARR_API_KEY
        quality_definition:
          type: movie
        quality_profiles:
          - name: HD Bluray + WEB
            score_set: default
          - name: UHD Bluray + WEB
            score_set: default
  '';
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/arr-stack/sabnzbd   0755 root root -"
    "d /var/lib/arr-stack/recyclarr 0755 1000 1000 -"
  ];

  virtualisation.quadlet = {
    volumes = {
      arr-lidarr = {};
      arr-radarr = {};
      arr-sonarr = {};
      arr-whisparr = {};
      arr-prowlarr = {};
    };

    containers.lidarr = {
      containerConfig = {
        image = "lscr.io/linuxserver/lidarr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = commonEnv;
        volumes = [
          "${volumes.arr-lidarr.ref}:/config"
          "/storage/media/music/lidarr:/music"
          "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Downloads"
          "homepage.name=Lidarr"
          "homepage.icon=lidarr.png"
          "homepage.href=https://lidarr.jennex.dev"
          "homepage.description=Music"
          "traefik.enable=true"
          "traefik.http.routers.lidarr.rule=Host(`lidarr.jennex.dev`)"
          "traefik.http.routers.lidarr-secure.entrypoints=https"
          "traefik.http.routers.lidarr-secure.rule=Host(`lidarr.jennex.dev`)"
          "traefik.http.routers.lidarr-secure.tls=true"
          "traefik.http.services.lidarr.loadbalancer.server.port=8686"
        ];
      };
    };

    containers.radarr = {
      containerConfig = {
        image = "lscr.io/linuxserver/radarr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = commonEnv;
        volumes = [
          "${volumes.arr-radarr.ref}:/config"
          "/storage/media/movies:/movies"
          "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Downloads"
          "homepage.name=Radarr"
          "homepage.icon=radarr.png"
          "homepage.href=https://radarr.jennex.dev"
          "homepage.description=Movies"
          "traefik.enable=true"
          "traefik.http.routers.radarr.rule=Host(`radarr.jennex.dev`)"
          "traefik.http.routers.radarr-secure.entrypoints=https"
          "traefik.http.routers.radarr-secure.rule=Host(`radarr.jennex.dev`)"
          "traefik.http.routers.radarr-secure.tls=true"
          "traefik.http.services.radarr.loadbalancer.server.port=7878"
        ];
      };
    };

    containers.sonarr = {
      containerConfig = {
        image = "lscr.io/linuxserver/sonarr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = commonEnv;
        volumes = [
          "${volumes.arr-sonarr.ref}:/config"
          "/storage/media/tv:/tv"
          "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Downloads"
          "homepage.name=Sonarr"
          "homepage.icon=sonarr.png"
          "homepage.href=https://sonarr.jennex.dev"
          "homepage.description=TV Shows"
          "traefik.enable=true"
          "traefik.http.routers.sonarr.rule=Host(`sonarr.jennex.dev`)"
          "traefik.http.routers.sonarr-secure.entrypoints=https"
          "traefik.http.routers.sonarr-secure.rule=Host(`sonarr.jennex.dev`)"
          "traefik.http.routers.sonarr-secure.tls=true"
          "traefik.http.services.sonarr.loadbalancer.server.port=8989"
        ];
      };
    };

    containers.whisparr = {
      containerConfig = {
        image = "ghcr.io/hotio/whisparr:nightly";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = commonEnv;
        volumes = [
          "${volumes.arr-whisparr.ref}:/config"
          "/storage/media/whisparr/data:/data"
          "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.whisparr.rule=Host(`whisparr.jennex.dev`)"
          "traefik.http.routers.whisparr-secure.entrypoints=https"
          "traefik.http.routers.whisparr-secure.rule=Host(`whisparr.jennex.dev`)"
          "traefik.http.routers.whisparr-secure.tls=true"
          "traefik.http.services.whisparr.loadbalancer.server.port=6969"
        ];
      };
    };

    containers.prowlarr = {
      containerConfig = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = commonEnv;
        volumes = ["${volumes.arr-prowlarr.ref}:/config"];
        labels = [
          "homepage.group=Downloads"
          "homepage.name=Prowlarr"
          "homepage.icon=prowlarr.png"
          "homepage.href=https://prowlarr.jennex.dev"
          "homepage.description=Usenet Indexer"
          "traefik.enable=true"
          "traefik.http.routers.prowlarr.rule=Host(`prowlarr.jennex.dev`)"
          "traefik.http.routers.prowlarr-secure.entrypoints=https"
          "traefik.http.routers.prowlarr-secure.rule=Host(`prowlarr.jennex.dev`)"
          "traefik.http.routers.prowlarr-secure.tls=true"
          "traefik.http.services.prowlarr.loadbalancer.server.port=9696"
        ];
      };
    };

    containers.sabnzbd = {
      containerConfig = {
        image = "lscr.io/linuxserver/sabnzbd:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        environments = commonEnv;
        volumes = [
          "/var/lib/arr-stack/sabnzbd:/config"
          "/storage/media/downloads/sabnzbd/downloads:/downloads"
          "/storage/media/downloads/sabnzbd/incomplete:/incomplete-downloads"
        ];
        labels = [
          "homepage.group=Downloads"
          "homepage.name=SABnzbd"
          "homepage.icon=sabnzbd.png"
          "homepage.href=https://sabnzbd.jennex.dev"
          "homepage.description=Downloader"
          "traefik.enable=true"
          "traefik.http.routers.sabnzbd.rule=Host(`sabnzbd.jennex.dev`)"
          "traefik.http.routers.sabnzbd-secure.entrypoints=https"
          "traefik.http.routers.sabnzbd-secure.rule=Host(`sabnzbd.jennex.dev`)"
          "traefik.http.routers.sabnzbd-secure.tls=true"
          "traefik.http.services.sabnzbd.loadbalancer.server.port=8080"
        ];
      };
    };

    containers.recyclarr = {
      unitConfig = {
        After = ["opnix-secrets.service" "recyclarr-env-setup.service"];
        Requires = ["opnix-secrets.service" "recyclarr-env-setup.service"];
      };
      serviceConfig = {
        Restart = "no";
      };
      containerConfig = {
        image = "ghcr.io/recyclarr/recyclarr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        user = "1000:1000";
        exec = "sync";
        environments = {TZ = "America/Los_Angeles";};
        environmentFiles = ["/run/opnix/recyclarr-env"];
        volumes = [
          "/var/lib/arr-stack/recyclarr:/config"
          "${recyclarrConfig}:/config/recyclarr.yml:ro"
        ];
      };
    };
  };

  systemd.timers.recyclarr = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "6h";
      RandomizedDelaySec = "5min";
      Unit = "recyclarr.service";
    };
  };

  systemd.services.recyclarr-env-setup = {
    description = "Build recyclarr environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["recyclarr.service"];
    wantedBy = ["recyclarr.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "recyclarr-env-setup";
        text = ''
          {
            printf 'SONARR_API_KEY=%s\n' "$(cat /run/opnix/recyclarr-sonarr-api-key)"
            printf 'RADARR_API_KEY=%s\n' "$(cat /run/opnix/recyclarr-radarr-api-key)"
          } > /run/opnix/recyclarr-env
          chmod 600 /run/opnix/recyclarr-env
        '';
      });
    };
  };
}
