# Arr-stack — media management suite
#
# No secrets required — all configuration stored in volumes.
#
# Media paths (/storage/media/*) are commented out — only available on nauvoo.
# All arr services share the sabnzbd downloads path for cross-service hardlinking.
{config, ...}: let
  inherit (config.virtualisation.quadlet) networks volumes;

  commonEnv = {
    PUID = "1000";
    PGID = "1000";
    TZ = "America/Los_Angeles";
  };
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/arr-stack/sabnzbd   0755 root root -"
    "d /var/lib/arr-stack/recyclarr 0755 root root -"
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
          # Uncomment when deployed to nauvoo (paths only available there)
          # "/storage/media/music/lidarr:/music"
          # "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Arr-Stack"
          "homepage.name=Lidarr"
          "homepage.icon=lidarr.png"
          "homepage.href=https://lidarr.deatrin.dev"
          "homepage.description=Music"
          "traefik.enable=true"
          "traefik.http.routers.lidarr.rule=Host(`lidarr.deatrin.dev`)"
          "traefik.http.routers.lidarr-secure.entrypoints=https"
          "traefik.http.routers.lidarr-secure.rule=Host(`lidarr.deatrin.dev`)"
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
          # Uncomment when deployed to nauvoo (paths only available there)
          # "/storage/media/movies:/movies"
          # "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Arr-Stack"
          "homepage.name=Radarr"
          "homepage.icon=radarr.png"
          "homepage.href=https://radarr.deatrin.dev"
          "homepage.description=Movies"
          "traefik.enable=true"
          "traefik.http.routers.radarr.rule=Host(`radarr.deatrin.dev`)"
          "traefik.http.routers.radarr-secure.entrypoints=https"
          "traefik.http.routers.radarr-secure.rule=Host(`radarr.deatrin.dev`)"
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
          # Uncomment when deployed to nauvoo (paths only available there)
          # "/storage/media/tv:/tv"
          # "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Arr-Stack"
          "homepage.name=Sonarr"
          "homepage.icon=sonarr.png"
          "homepage.href=https://sonarr.deatrin.dev"
          "homepage.description=TV Shows"
          "traefik.enable=true"
          "traefik.http.routers.sonarr.rule=Host(`sonarr.deatrin.dev`)"
          "traefik.http.routers.sonarr-secure.entrypoints=https"
          "traefik.http.routers.sonarr-secure.rule=Host(`sonarr.deatrin.dev`)"
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
          # Uncomment when deployed to nauvoo (paths only available there)
          # "/storage/media/whisparr/data:/data"
          # "/storage/media/downloads/sabnzbd:/downloads"
        ];
        labels = [
          "homepage.group=Arr-Stack"
          "homepage.name=Whisparr"
          "homepage.icon=whisparr.png"
          "homepage.href=https://whisparr.deatrin.dev"
          "homepage.description=Shhhh"
          "traefik.enable=true"
          "traefik.http.routers.whisparr.rule=Host(`whisparr.deatrin.dev`)"
          "traefik.http.routers.whisparr-secure.entrypoints=https"
          "traefik.http.routers.whisparr-secure.rule=Host(`whisparr.deatrin.dev`)"
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
          "homepage.group=Arr-Stack"
          "homepage.name=Prowlarr"
          "homepage.icon=prowlarr.png"
          "homepage.href=https://prowlarr.deatrin.dev"
          "homepage.description=Usenet Indexer"
          "traefik.enable=true"
          "traefik.http.routers.prowlarr.rule=Host(`prowlarr.deatrin.dev`)"
          "traefik.http.routers.prowlarr-secure.entrypoints=https"
          "traefik.http.routers.prowlarr-secure.rule=Host(`prowlarr.deatrin.dev`)"
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
          # Uncomment when deployed to nauvoo (paths only available there)
          # "/storage/media/downloads/sabnzbd/downloads:/downloads"
          # "/storage/media/downloads/sabnzbd/incomplete:/incomplete-downloads"
        ];
        labels = [
          "homepage.group=Arr-Stack"
          "homepage.name=SABnzbd"
          "homepage.icon=sabnzbd.png"
          "homepage.href=https://sabnzbd.deatrin.dev"
          "homepage.description=Downloader"
          "traefik.enable=true"
          "traefik.http.routers.sabnzbd.rule=Host(`sabnzbd.deatrin.dev`)"
          "traefik.http.routers.sabnzbd-secure.entrypoints=https"
          "traefik.http.routers.sabnzbd-secure.rule=Host(`sabnzbd.deatrin.dev`)"
          "traefik.http.routers.sabnzbd-secure.tls=true"
          "traefik.http.services.sabnzbd.loadbalancer.server.port=8080"
        ];
      };
    };

    containers.recyclarr = {
      containerConfig = {
        image = "ghcr.io/recyclarr/recyclarr:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref];
        user = "1000:1000";
        environments = {TZ = "America/Los_Angeles";};
        volumes = ["/var/lib/arr-stack/recyclarr:/config"];
      };
    };
  };
}
