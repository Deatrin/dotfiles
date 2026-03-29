{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/netboot 0755 root root -"
    "d /var/lib/netboot/config 0755 root root -"
  ];

  virtualisation.quadlet.containers.netboot = {
    containerConfig = {
      image = "ghcr.io/netbootxyz/netbootxyz:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      publishPorts = ["0.0.0.0:69:69/udp"];
      volumes = ["/var/lib/netboot/config:/config"];
      labels = [
        "homepage.group=Network"
        "homepage.name=netboot.xyz"
        "homepage.icon=netboot-xyz.png"
        "homepage.href=https://netboot.jennex.dev"
        "homepage.description=Network Boot Manager"
        "traefik.enable=true"
        "traefik.http.routers.netboot.rule=Host(`netboot.jennex.dev`)"
        "traefik.http.routers.netboot-secure.entrypoints=https"
        "traefik.http.routers.netboot-secure.rule=Host(`netboot.jennex.dev`)"
        "traefik.http.routers.netboot-secure.tls=true"
        "traefik.http.services.netboot.loadbalancer.server.port=3000"
      ];
    };
  };
}
