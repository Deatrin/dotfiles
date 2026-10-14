{self, ...}: {
  flake.modules.nixos.netboot = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.netboot;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.netboot.enable = lib.mkEnableOption "netboot.xyz network boot manager";

    config = lib.mkIf cfg.enable {
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
          labels = self.lib.webLabels {
            host = "netboot.jennex.dev";
            router = "netboot";
            port = 3000;
            homepage = {
              group = "Network";
              name = "netboot.xyz";
              icon = "netboot-xyz.png";
              description = "Network Boot Manager";
            };
          };
        };
      };
    };
  };
}
