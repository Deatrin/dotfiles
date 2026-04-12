{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/kavita 0755 root root -"
  ];

  virtualisation.quadlet.containers.kavita = {
    containerConfig = {
      image = "docker.io/jvmilazz0/kavita:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      volumes = [
        "/var/lib/kavita:/kavita/config"
        "/storage/media/books:/books:ro"
        "/storage/media/manga:/manga:ro"
      ];
      labels = [
        "homepage.group=Media"
        "homepage.name=Kavita"
        "homepage.icon=kavita.png"
        "homepage.href=https://kavita.jennex.dev"
        "homepage.description=Manga, Comics & Books"
        "traefik.enable=true"
        "traefik.http.routers.kavita.rule=Host(`kavita.jennex.dev`)"
        "traefik.http.routers.kavita-secure.entrypoints=https"
        "traefik.http.routers.kavita-secure.rule=Host(`kavita.jennex.dev`)"
        "traefik.http.routers.kavita-secure.tls=true"
        "traefik.http.services.kavita.loadbalancer.server.port=5000"
      ];
    };
  };
}
