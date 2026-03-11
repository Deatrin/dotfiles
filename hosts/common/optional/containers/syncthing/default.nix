# Syncthing — P2P file synchronization
#
# No secrets required — configure devices/folders via web UI on first run.
# Sync port 22000 is published directly (not via Traefik).
# Web UI available at syncthing.jennex.dev via Traefik.
{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/syncthing 0755 1000 1000 -"
  ];

  # Open sync port in firewall (TCP + UDP)
  networking.firewall.allowedTCPPorts = [22000];
  networking.firewall.allowedUDPPorts = [22000];

  virtualisation.quadlet.containers.syncthing = {
    containerConfig = {
      image = "docker.io/syncthing/syncthing:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      publishPorts = [
        "22000:22000/tcp"
        "22000:22000/udp"
      ];
      environments = {
        TZ = "America/Los_Angeles";
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/var/lib/syncthing:/var/syncthing"
        "/storage/media:/storage/media"
      ];
      labels = [
        "homepage.group=Infrastructure"
        "homepage.name=Syncthing"
        "homepage.icon=syncthing.png"
        "homepage.href=https://syncthing.jennex.dev"
        "homepage.description=File Sync"
        "traefik.enable=true"
        "traefik.http.routers.syncthing.rule=Host(`syncthing.jennex.dev`)"
        "traefik.http.routers.syncthing-secure.entrypoints=https"
        "traefik.http.routers.syncthing-secure.rule=Host(`syncthing.jennex.dev`)"
        "traefik.http.routers.syncthing-secure.tls=true"
        "traefik.http.services.syncthing.loadbalancer.server.port=8384"
      ];
    };
  };
}
