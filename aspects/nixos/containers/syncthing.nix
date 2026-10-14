# Syncthing — P2P file synchronization
#
# No secrets required — configure devices/folders via web UI on first run.
# Sync port 22000 is published directly (not via Traefik).
# Web UI available at syncthing.jennex.dev via Traefik.
{self, ...}: {
  flake.modules.nixos.syncthing = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.syncthing;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.syncthing.enable = lib.mkEnableOption "Syncthing P2P file sync";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/syncthing 0755 1000 1000 -"
        "d /storage/syncthing 0755 1000 1000 -"
        "d /home/deatrin/Sync 0755 1000 1000 -"
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
            "/storage/syncthing:/storage/syncthing"
            "/storage/media:/storage/media"
            # Same host path on both sides so it lines up with the symlink the
            # claude.memorySync home-manager activation script creates at
            # ~/Sync/claude-memory-dotfiles (see aspects/homeManager/claude.nix).
            "/home/deatrin/Sync:/home/deatrin/Sync"
          ];
          labels = self.lib.webLabels {
            host = "syncthing.jennex.dev";
            router = "syncthing";
            port = 8384;
            homepage = {
              group = "System";
              name = "Syncthing";
              icon = "syncthing.png";
              description = "File Sync";
            };
          };
        };
      };
    };
  };
}
