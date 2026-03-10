{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/audiobookshelf/config 0755 root root -"
    "d /var/lib/audiobookshelf/metadata 0755 root root -"
  ];

  virtualisation.quadlet.containers.audiobookshelf = {
    containerConfig = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      environments = {
        TZ = "America/Los_Angeles";
      };
      volumes = [
        # Uncomment when deployed to nauvoo (paths only available there)
        # "/storage/media/audiobooks:/audiobooks"
        # "/storage/media/audiobooks:/podcasts"
        "/var/lib/audiobookshelf/config:/config"
        "/var/lib/audiobookshelf/metadata:/metadata"
      ];
      labels = [
        "homepage.group=Self-Hosted"
        "homepage.name=Audiobookshelf"
        "homepage.icon=audiobookshelf.png"
        "homepage.href=https://audiobookshelf.deatrin.dev"
        "homepage.description=Audiobook player"
        "traefik.enable=true"
        "traefik.http.routers.audiobookshelf.rule=Host(`audiobookshelf.deatrin.dev`)"
        "traefik.http.routers.audiobookshelf-secure.entrypoints=https"
        "traefik.http.routers.audiobookshelf-secure.rule=Host(`audiobookshelf.deatrin.dev`)"
        "traefik.http.routers.audiobookshelf-secure.tls=true"
        "traefik.http.services.audiobookshelf.loadbalancer.server.port=80"
      ];
    };
  };
}
