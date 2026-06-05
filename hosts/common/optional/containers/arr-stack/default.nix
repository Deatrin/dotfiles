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
      sonarr:
        base_url: http://sonarr:8989
        api_key: !env_var SONARR_API_KEY
        quality_definition:
          type: series
        quality_profiles:
          - name: WEB-1080p
            score_set: default
            reset_unmatched_scores:
              enabled: true
          - name: WEB-2160p
            score_set: default
            reset_unmatched_scores:
              enabled: true
        custom_formats:
          - trash_ids:
              # HQ Source Groups
              - e6258996055b9fbab7e9cb2f75819294 # WEB Tier 01
              - 58790d4e2fdcd9733aa7ae68ba2bb503 # WEB Tier 02
              - d84935abd3f8556dcd51d4f27e22d0a6 # WEB Tier 03
              - d0c516558625b04b363fa6c5c2c7cfd4 # WEB Scene
              # Streaming Services
              - d660701077794679fd59e8bdf4ce3a29 # AMZN
              - f67c9ca88f463a48346062e8ad07713f # ATVP
              - 77a7b25585c18af08f60b1547bb9b4fb # CC
              - 36b72f59f4ea20aad9316f475f2d9fbb # DCU
              - 89358767a60cc28783cdc3d0be9388a4 # DSNP
              - a880d6abc21e7c16884f3ae393f84179 # HMAX
              - 7a235133c87f7da4c8cccceca7e3c7a6 # HBO
              - f6cce30f1733d5c8194222a7507909bb # HULU
              - 0ac24a2a68a9700bcb7eeca8e5cd644c # iT
              - 81d1fbf600e2540cee87f3a23f9d3c1c # MAX
              - d34870697c9db575f17700212167be23 # NF
              - c67a75ae4a1715f2bb4d492755ba4195 # PMTP
              - 1656adc6d7bb2c8cca6acfb6592db421 # PCOK
              - 6eb71887a8db6e783dd398446eb0e65d # PLAY
              - ae58039e1319178e6be73caab5c42166 # SHO
              - 1efe8da11bfd74fbbcd4d8117ddb9213 # STAN
              - 9623c5c9cac8e939c1b9aedd32f640bf # SYFY
              - 218e93e5702f44a68ad9e3c6ba87d2f0 # HD Streaming Boost
              # Misc
              - ec8fa7296b64e8cd390a1600981f3923 # Repack/Proper
              - eb3d5cc0a2be0db205fb823640db6a3c # Repack2
              - 44e7c4de10ae50265753082e5dc76047 # Repack3
              # Unwanted
              - 85c61753df5da1fb2aab6f2a47426b09 # BR-DISK
              - 9c11cd3f07101cdba90a2d81cf0e56b4 # LQ
              - e2315f990da2e2cbfc9fa5b7a6fcfe48 # LQ (Release Title)
              - 47435ece6b99a0b477caf360e79ba0bb # x265 (HD)
              - fbcb31d8dabd2a319072b84fc0b7249c # Extras
              - 15a05bc7c1a36e2b57fd628f8977e2fc # AV1
              - 32b367365729d530ca1c124a0b180c64 # Bad Dual Groups
              - 82d40da2bc6923f41e14394075dd4b03 # No-RlsGroup
              - e1a997ddb54e3ecbfe06341ad323c458 # Obfuscated
              - 06d66ab109d4d2eddb2794d21526d140 # Retags
              - 1b3994c551cbb92a2c781af061f4ab44 # Scene
            quality_profiles:
              - name: WEB-1080p
              - name: WEB-2160p
          - trash_ids:
              # HDR Formats
              - 505d871304820ba7106b693be6fe4a9e # HDR
              - 7c3a61a9c6cb04f52f1544be6d44a026 # DV Boost
              - 0c4b99df9206d2cfac3c05ab897dd62a # HDR10+ Boost
              - 9b27ab6498ec0f31a3353992e19434ca # DV (w/o HDR fallback)
              # Unwanted UHD
              - 2016d1676f5ee13a5b7257ff86ac9a93 # SDR
              - 83304f261cf516bb208c18c54c0adf97 # SDR (no WEBDL)
              - 9b64dff695c2115facf1b6ea59c9bd07 # x265 (no HDR/DV)
            quality_profiles:
              - name: WEB-2160p

    radarr:
      radarr:
        base_url: http://radarr:7878
        api_key: !env_var RADARR_API_KEY
        quality_definition:
          type: movie
        quality_profiles:
          - name: Remux + WEB 1080p
            score_set: default
            reset_unmatched_scores:
              enabled: true
          - name: Remux + WEB 2160p
            score_set: default
            reset_unmatched_scores:
              enabled: true
        custom_formats:
          - trash_ids:
              # HQ Release Groups
              - 3a3ff47579026e76d6504ebea39390de # Remux Tier 01
              - 9f98181fe5a3fbeb0cc29340da2a468a # Remux Tier 02
              - 8baaf0b3142bf4d94c42a724f034e27a # Remux Tier 03
              - c20f169ef63c5f40c2def54abaf4438e # WEB Tier 01
              - 403816d65392c79236dcb6dd591aeda4 # WEB Tier 02
              - af94e0fe497124d1f9ce732069ec8c3b # WEB Tier 03
              # Streaming Services
              - b3b3a6ac74ecbd56bcdbefa4799fb9df # AMZN
              - df13ed57843877b21ad969184ab6888f # ATV
              - 40e9380490e748672c2522eaaeb692f7 # ATVP
              - 84272245b2988854bfb76a16e60baea5 # DSNP
              - 509e5f41146e278f9eab1ddaceb34515 # HBO
              - 5763d1b0ce84aff3b21038eea8e9b8ad # HMAX
              - 526d445d4c16214309f0fd2b3be18a89 # Hulu
              - e0ec9672be6cac914ffad34a6b077209 # iT
              - 6a061313d22e51e0f25b7cd4dc065233 # MAX
              - 2a6039655313bf5dab1e43523b62c374 # MA
              - 170b1d363bd8516fbf3a3eb05d4faff6 # NF
              - e36a0ba1bc902b26ee40818a1d59b8bd # PMTP
              - c9fd353f8f5f1baf56dc601c4cb29920 # PCOK
              - cc5e51a9e85a6296ceefe097a77f12f4 # BCORE
              - 16622a6911d1ab5d5b8b713d5b0036d4 # CRiT
              # Audio Formats
              - 496f355514737f7d83bf7aa4d24f8169 # TrueHD ATMOS
              - 2f22d89048b01681dde8afe203bf2e95 # DTS X
              - 417804f7f2c4308c1f4c5d380d4c4475 # ATMOS (undefined)
              - 1af239278386be2919e1bcee0bde047e # DD+ ATMOS
              - 3cafb66171b47f226146a0770576870f # TrueHD
              - dcf3ec6938fa32445f590a4da84256cd # DTS-HD MA
              - a570d4a0e56a2874b64e5bfa55202a1b # FLAC
              - e7c2fcae07cbada050a0af3357491d7b # PCM
              - 8e109e50e0a0b83a5098b056e13bf6db # DTS-HD HRA
              - 185f1dd7264c4562b9022d963ac37424 # DD+
              - f9f847ac70a0af62ea4a08280b859636 # DTS-ES
              - 1c1a4c5e823891c75bc50380a6866f73 # DTS
              - 240770601cc226190c367ef59aba7463 # AAC
              - c2998bd0d90ed5621d8df281e839436e # DD
              # Misc
              - e7718d7a3ce595f289bfee26adc178f5 # Repack/Proper
              - ae43b294509409a6a13919dedd4764c4 # Repack2
              - 5caaaa1c08c1742aa4342d8c4cc463f2 # Repack3
              # Unwanted
              - ed38b889b31be83fda192888e2286d83 # BR-DISK
              - e6886871085226c3da1830830146846c # Generated Dynamic HDR
              - 90a6f9a284dff5103f6346090e6280c8 # LQ
              - e204b80c87be9497a8a6eaff48f72905 # LQ (Release Title)
              - dc98083864ea246d05a42df0d05f81cc # x265 (HD)
              - b8cd450cbfa689c0259a01d9e29ba3d6 # 3D
              - 0a3f082873eb454bde444150b70253cc # Extras
              - 712d74cd88bceb883ee32f773656b1f5 # Sing-Along Versions
              - cae4ca30163749b891686f95532519bd # AV1
            quality_profiles:
              - name: Remux + WEB 1080p
              - name: Remux + WEB 2160p
          - trash_ids:
              # HDR Formats
              - 493b6d1dbec3c3364c59d7607f7e3405 # HDR
              - b337d6812e06c200ec9a2d3cfa9d20a7 # DV Boost
              - caa37d0df9c348912df1fb1d88f9273a # HDR10+ Boost
              - 923b6abef9b17f937fab56cfcf89e1f1 # DV (w/o HDR fallback)
              # Unwanted UHD
              - 9c38ebb7384dada637be8899efa68e6f # SDR
              - 25c12f78430a3a23413652cbd1d48d77 # SDR (no WEBDL)
              - 839bea857ed2c0a8e084f3cbdbd65ecb # x265 (no HDR/DV)
            quality_profiles:
              - name: Remux + WEB 2160p
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
