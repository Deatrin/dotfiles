# Homepage dashboard
#
# Config files are Nix-managed and copied to /var/lib/homepage/config at
# activation — homepage needs a writable directory for logs.
#
# Secrets required (via opnix):
#   /run/opnix/homepage-unifi-user
#   /run/opnix/homepage-unifi-pass
#   /run/opnix/homepage-latitude
#   /run/opnix/homepage-longitude
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;

  settingsYaml = pkgs.writeText "homepage-settings.yaml" ''
    ---
    title: Homelab Homepage

    favicon: https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/homepage.png
    theme: dark
    background:
      image: https://raw.githubusercontent.com/Deatrin/dotfiles/main/wallpapers/chill_firewatch.png
      opacity: 25
    color: slate
    headerStyle: clean
    quicklaunch:
      searchDescriptions: true
      hideInternetSearch: true
      showSearchSuggestions: true
      hideVisitURL: true

    layout:
      Network:
        icon: mdi-network
        style: row
        columns: 2
      Media:
        icon: mdi-television-play
      Downloads:
        icon: mdi-download-circle
        style: row
        columns: 4
      System:
        icon: mdi-server
        style: row
        columns: 3
      Home:
        icon: mdi-home-heart
        style: row
        columns: 2
      Dev & Games:
        icon: mdi-controller
        style: row
        columns: 3
  '';

  servicesYaml = pkgs.writeText "homepage-services.yaml" ''
    ---
    - Network:
        - Unifi:
            href: https://10.1.1.1
            icon: unifi.png
            description: Unifi Dashboard
            widget:
              type: unifi
              url: https://10.1.1.1:443
              username: '{{HOMEPAGE_VAR_UNIFI_USER}}'
              password: '{{HOMEPAGE_VAR_UNIFI_PASS}}'
        - Traefik:
            href: https://traefik.jennex.dev
            icon: traefik.png
            description: Reverse Proxy
            widget:
              type: traefik
              url: https://traefik.jennex.dev
              username: '{{HOMEPAGE_VAR_TRAEFIK_USERNAME}}'
              password: '{{HOMEPAGE_VAR_TRAEFIK_PASSWORD}}'
        - Pi-hole:
            href: https://pihole.jennex.dev/admin
            icon: pi-hole.png
            description: DNS & Ad Blocking
            widget:
              type: pihole
              url: https://pihole.jennex.dev
              version: 6
              key: '{{HOMEPAGE_VAR_PIHOLE_PASSWORD}}'
    - Media:
        - Plex:
            href: https://plex.jennex.dev
            icon: plex.png
            description: Media Server
            widget:
              type: plex
              url: https://plex.jennex.dev
              key: '{{HOMEPAGE_VAR_PLEX_TOKEN}}'
    - System:
        - Home Assistant:
            href: http://10.1.1.123:8123
            icon: home-assistant.png
            description: Home Automation
        - Proxmox:
            href: https://10.1.20.20:8006
            icon: proxmox.png
            description: Proxmox VE
            widget:
              type: proxmox
              url: https://10.1.20.20:8006
              username: '{{HOMEPAGE_VAR_PROXMOX_TOKEN_ID}}'
              password: '{{HOMEPAGE_VAR_PROXMOX_TOKEN_SECRET}}'
        - Proxmox iDRAC:
            href: https://10.1.20.10
            icon: idrac.png
            description: Proxmox Server iDRAC
        - TrueNAS iDRAC:
            href: https://10.1.20.15
            icon: idrac.png
            description: TrueNAS Server iDRAC
  '';

  dockerYaml = pkgs.writeText "homepage-docker.yaml" ''
    ---
    nauvoo-podman:
      socket: /var/run/docker.sock
  '';

  bookmarksYaml = pkgs.writeText "homepage-bookmarks.yaml" ''
    ---
    - Communicate:
        - Discord:
            - icon: discord.png
              href: 'https://discord.com/app'
        - Gmail:
            - icon: gmail.png
              href: 'http://gmail.com'
        - Google Calendar:
            - icon: google-calendar.png
              href: 'https://calendar.google.com'

    - Media:
        - YouTube:
            - icon: youtube.png
              href: 'https://youtube.com/feed/subscriptions'
        - Spotify:
            - icon: spotify.png
              href: 'http://open.spotify.com'

    - Reading:
        - Reddit:
            - icon: reddit.png
              href: 'https://reddit.com'

    - Git:
        - kubesearch:
            - icon: kubernetes-dashboard.png
              href: 'https://kubesearch.dev/'
        - home-ops:
            - icon: github.png
              href: 'https://github.com/Deatrin/Home-Ops'
  '';

  widgetsYaml = pkgs.writeText "homepage-widgets.yaml" ''
    ---
    - greeting:
        text_size: xl
        text: Greetings, Drew!

    - resources:
        cpu: true
        memory: true
        disk: /

    - search:
        provider: [duckduckgo, google]
        focus: false
        target: _blank

    - openmeteo:
        label: Home
        latitude: '{{HOMEPAGE_VAR_LATITUDE}}'
        longitude: '{{HOMEPAGE_VAR_LONGITUDE}}'
        timezone: America/Los_Angeles
        units: imperial
        cache: 5

    - datetime:
        text_size: l
        format:
          dateStyle: long
          timeStyle: short
          hourCycle: h23

    - unifi_console:
        url: https://10.1.1.1:443
        username: '{{HOMEPAGE_VAR_UNIFI_USER}}'
        password: '{{HOMEPAGE_VAR_UNIFI_PASS}}'
  '';
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/homepage/config 0755 root root -"
  ];

  # Build homepage env file from individual opnix secrets
  systemd.services.homepage-env-setup = {
    description = "Build Homepage environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["homepage.service"];
    wantedBy = ["homepage.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "homepage-env-setup";
        text = ''
          {
            printf 'HOMEPAGE_VAR_UNIFI_USER=%s\n' "$(cat /run/opnix/homepage-unifi-user)"
            printf 'HOMEPAGE_VAR_UNIFI_PASS=%s\n' "$(cat /run/opnix/homepage-unifi-pass)"
            printf 'HOMEPAGE_VAR_LATITUDE=%s\n' "$(cat /run/opnix/homepage-latitude)"
            printf 'HOMEPAGE_VAR_LONGITUDE=%s\n' "$(cat /run/opnix/homepage-longitude)"
            printf 'HOMEPAGE_VAR_TRAEFIK_USERNAME=%s\n' "$(cat /run/opnix/homepage-traefik-username)"
            printf 'HOMEPAGE_VAR_TRAEFIK_PASSWORD=%s\n' "$(cat /run/opnix/homepage-traefik)"
            printf 'HOMEPAGE_VAR_PIHOLE_PASSWORD=%s\n' "$(cat /run/opnix/homepage-pihole)"
            printf 'HOMEPAGE_VAR_PLEX_TOKEN=%s\n'          "$(cat /run/opnix/plex-token)"
            printf 'HOMEPAGE_VAR_PROXMOX_TOKEN_ID=%s\n'     "$(cat /run/opnix/proxmox-token-id)"
            printf 'HOMEPAGE_VAR_PROXMOX_TOKEN_SECRET=%s\n' "$(cat /run/opnix/proxmox-token-secret)"
          } > /run/opnix/homepage-env
          chmod 600 /run/opnix/homepage-env
        '';
      });
    };
  };

  # Copy Nix-managed config files into writable directory at activation
  systemd.services.homepage-config-setup = {
    description = "Deploy Homepage config files from Nix store";
    before = ["homepage.service"];
    wantedBy = ["homepage.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "homepage-config-setup";
        text = ''
          mkdir -p /var/lib/homepage/config
          cp -f ${settingsYaml}  /var/lib/homepage/config/settings.yaml
          cp -f ${servicesYaml}  /var/lib/homepage/config/services.yaml
          cp -f ${dockerYaml}    /var/lib/homepage/config/docker.yaml
          cp -f ${bookmarksYaml} /var/lib/homepage/config/bookmarks.yaml
          cp -f ${widgetsYaml}   /var/lib/homepage/config/widgets.yaml
        '';
      });
    };
  };

  virtualisation.quadlet.containers.homepage = {
    unitConfig = {
      After = [
        "opnix-secrets.service"
        "homepage-env-setup.service"
        "homepage-config-setup.service"
      ];
      Requires = [
        "opnix-secrets.service"
        "homepage-env-setup.service"
        "homepage-config-setup.service"
      ];
    };
    containerConfig = {
      image = "ghcr.io/gethomepage/homepage:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        HOMEPAGE_ALLOWED_HOSTS = "homepage.jennex.dev";
      };
      environmentFiles = ["/run/opnix/homepage-env"];
      volumes = [
        "/var/lib/homepage/config:/app/config"
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.homepage.rule=Host(`homepage.jennex.dev`)"
        "traefik.http.routers.homepage-secure.entrypoints=https"
        "traefik.http.routers.homepage-secure.rule=Host(`homepage.jennex.dev`)"
        "traefik.http.routers.homepage-secure.tls=true"
        "traefik.http.services.homepage.loadbalancer.server.port=3000"
      ];
    };
  };
}
