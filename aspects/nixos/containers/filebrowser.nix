# File Browser — web-based file manager for /storage/media/music cleanup
#
# No secrets involved: on first startup (no existing database) filebrowser
# auto-creates an 'admin' user with a randomly generated password, printed
# to the container's logs. Find it with:
#   sudo podman logs filebrowser
# Log in and change the password immediately from Settings > Profile.
{
  flake.modules.nixos.filebrowser = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.filebrowser;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.filebrowser.enable = lib.mkEnableOption "File Browser web file manager (music library)";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/filebrowser 0755 1000 1000 -"
      ];

      virtualisation.quadlet.containers.filebrowser = {
        containerConfig = {
          image = "docker.io/filebrowser/filebrowser:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          user = "1000:1000";
          environments = {
            FB_DATABASE = "/config/database.db";
            FB_ROOT = "/srv";
            # Non-root (user = 1000:1000 below) can't bind port 80.
            FB_PORT = "8080";
          };
          volumes = [
            "/var/lib/filebrowser:/config"
            "/storage/media/music:/srv"
          ];
          labels = [
            "homepage.group=Media"
            "homepage.name=File Browser"
            "homepage.icon=filebrowser.png"
            "homepage.href=https://filebrowser.jennex.dev"
            "homepage.description=Music library cleanup"
            "traefik.enable=true"
            "traefik.http.routers.filebrowser.rule=Host(`filebrowser.jennex.dev`)"
            "traefik.http.routers.filebrowser-secure.entrypoints=https"
            "traefik.http.routers.filebrowser-secure.rule=Host(`filebrowser.jennex.dev`)"
            "traefik.http.routers.filebrowser-secure.tls=true"
            "traefik.http.services.filebrowser.loadbalancer.server.port=8080"
          ];
        };
      };
    };
  };
}
