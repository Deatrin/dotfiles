# Seedbox — qBittorrent behind Mullvad WireGuard, via gluetun
#
# Secrets required (via op-connect-secrets, see hosts/nixos/nauvoo/secrets.nix):
#   /run/opnix/seedbox-wireguard-conf — full Mullvad WireGuard .conf file contents
#   1Password: op://nix_secrets/seedbox/conf
#   Paste the whole wg-quick .conf file (as downloaded from
#   https://mullvad.net/en/account/wireguard-config) into that field —
#   seedbox-env-setup parses PrivateKey/Address out of it for gluetun, which
#   dials the actual Mullvad server itself (see SERVER_COUNTRIES below), so
#   the [Peer] section of the file is unused.
#
# gluetun is the only container that joins a Podman network — it's the
# Mullvad VPN gateway and kill switch. qbittorrent has no network of its own:
# it rides gluetun's network namespace (--network=container:gluetun), so if
# the tunnel drops, qbittorrent loses all connectivity outright. Because of
# that, Traefik routing labels live on gluetun (pointing at qbittorrent's
# WebUI port), not on qbittorrent itself.
#
# qBittorrent is not auto-registered as a download client — add it manually
# in each *arr's Settings > Download Clients (host: qbittorrent, port: 8080).
# Shares /storage/media/downloads/qbittorrent with sonarr/radarr/lidarr (see
# arr-stack.nix) so completed torrents can be hardlinked instead of copied.
{
  flake.modules.nixos.seedbox = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.dotfiles.seedbox;
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    options.dotfiles.seedbox.enable = lib.mkEnableOption "Seedbox (qBittorrent behind Mullvad via gluetun)";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /storage/media/downloads/qbittorrent 0775 1000 1000 -"
      ];

      systemd.services.seedbox-env-setup = {
        description = "Build seedbox (gluetun) environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["gluetun.service"];
        wantedBy = ["gluetun.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "seedbox-env-setup";
            text = ''
              conf=/run/opnix/seedbox-wireguard-conf
              private_key=$(grep -m1 -E '^[[:space:]]*PrivateKey' "$conf" | sed -E 's/^[[:space:]]*PrivateKey[[:space:]]*=[[:space:]]*//' | tr -d '[:space:]')
              address=$(grep -m1 -E '^[[:space:]]*Address' "$conf" | sed -E 's/^[[:space:]]*Address[[:space:]]*=[[:space:]]*//' | tr -d '[:space:]')
              {
                printf 'WIREGUARD_PRIVATE_KEY=%s\n' "$private_key"
                printf 'WIREGUARD_ADDRESSES=%s\n'   "$address"
              } > /run/opnix/seedbox-env
              chmod 600 /run/opnix/seedbox-env
            '';
          });
        };
      };

      virtualisation.quadlet = {
        volumes = {
          seedbox-qbittorrent = {};
        };

        containers.gluetun = {
          unitConfig = {
            After = ["opnix-secrets.service" "seedbox-env-setup.service"];
            Requires = ["opnix-secrets.service" "seedbox-env-setup.service"];
          };
          containerConfig = {
            image = "docker.io/qmcgaw/gluetun:latest";
            autoUpdate = "registry";
            networks = [networks.traefik_network.ref];
            environments = {
              VPN_SERVICE_PROVIDER = "mullvad";
              VPN_TYPE = "wireguard";
              # Adjust to taste — see https://mullvad.net/en/servers (WireGuard)
              SERVER_COUNTRIES = "USA";
              FIREWALL_OUTBOUND_SUBNETS = "10.89.6.0/24"; # traefik_network bridge subnet
              TZ = "America/Los_Angeles";
            };
            environmentFiles = ["/run/opnix/seedbox-env"];
            podmanArgs = [
              "--cap-add=NET_ADMIN"
              "--device=/dev/net/tun:/dev/net/tun"
            ];
            labels = [
              "homepage.group=Downloads"
              "homepage.name=qBittorrent"
              "homepage.icon=qbittorrent.png"
              "homepage.href=https://qbittorrent.jennex.dev"
              "homepage.description=Torrent client (Mullvad)"
              "traefik.enable=true"
              "traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.jennex.dev`)"
              "traefik.http.routers.qbittorrent-secure.entrypoints=https"
              "traefik.http.routers.qbittorrent-secure.rule=Host(`qbittorrent.jennex.dev`)"
              "traefik.http.routers.qbittorrent-secure.tls=true"
              "traefik.http.services.qbittorrent.loadbalancer.server.port=8080"
            ];
          };
        };

        containers.qbittorrent = {
          unitConfig = {
            After = ["gluetun.service"];
            Requires = ["gluetun.service"];
          };
          containerConfig = {
            image = "lscr.io/linuxserver/qbittorrent:latest";
            autoUpdate = "registry";
            environments = {
              PUID = "1000";
              PGID = "1000";
              TZ = "America/Los_Angeles";
              WEBUI_PORT = "8080";
            };
            volumes = [
              "${volumes.seedbox-qbittorrent.ref}:/config"
              "/storage/media/downloads/qbittorrent:/downloads"
            ];
            podmanArgs = ["--network=container:gluetun"];
          };
        };
      };
    };
  };
}
