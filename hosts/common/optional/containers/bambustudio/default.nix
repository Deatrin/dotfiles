# BambuStudio — Bambu Lab 3D printing slicer (Selkies web desktop GUI)
#
# Secrets required (via opnix):
#   /run/opnix/bambustudio-env — env file containing:
#       CUSTOM_USER=<username>
#       PASSWORD=<password>
#
# Storage paths:
#   /var/lib/bambustudio — application config/profile data
#
# Routing (via Traefik):
#   bambustudio.jennex.dev → bambustudio:3001 (HTTPS internal, insecureSkipVerify already set)
#
# Security note:
#   The linuxserver image includes a terminal with passwordless sudo.
#   CUSTOM_USER/PASSWORD basic auth is the only gate — never expose port 3001 directly.
#   Access is restricted to Traefik TLS termination only.
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks;
  domain = "bambustudio.jennex.dev";
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/bambustudio 0755 root root -"
  ];

  systemd.services.bambustudio-env-setup = {
    description = "Build BambuStudio environment file from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["bambustudio.service"];
    wantedBy = ["bambustudio.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "bambustudio-env-setup";
        text = ''
          {
            printf 'CUSTOM_USER=%s\n' "$(cat /run/opnix/bambustudio-user)"
            printf 'PASSWORD=%s\n'    "$(cat /run/opnix/bambustudio-password)"
          } > /run/opnix/bambustudio-env
          chmod 600 /run/opnix/bambustudio-env
        '';
      });
    };
  };

  virtualisation.quadlet.containers.bambustudio = {
    unitConfig = {
      After = ["opnix-secrets.service" "bambustudio-env-setup.service"];
      Requires = ["opnix-secrets.service" "bambustudio-env-setup.service"];
    };
    containerConfig = {
      image = "lscr.io/linuxserver/bambustudio:latest";
      autoUpdate = "registry";
      networks = [networks.traefik_network.ref];
      shmSize = "1g";
      # CDI injects /dev/nvidia* but not /dev/dri/*; mount render node explicitly
      devices = ["nvidia.com/gpu=all" "/dev/dri/renderD128:/dev/dri/renderD128"];
      environments = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/Los_Angeles";
        DARK_MODE = "true";
        DRINODE = "/dev/dri/renderD128";
        # PIXELFLUX_WAYLAND omitted — requires KMS/GBM dumb buffer allocation
        # (DRM_IOCTL_MODE_CREATE_DUMB) which needs /dev/dri/card* master access,
        # not available via CDI. Standard EGL encoding works without it.
        TITLE = "BambuStudio";
      };
      environmentFiles = ["/run/opnix/bambustudio-env"];
      volumes = ["/var/lib/bambustudio:/config"];
      labels = [
        "homepage.group=Maker"
        "homepage.name=BambuStudio"
        "homepage.icon=mdi-printer-3d-nozzle"
        "homepage.href=https://${domain}"
        "homepage.description=Bambu Lab 3D Slicer"
        "traefik.enable=true"
        "traefik.http.routers.bambustudio-secure.entrypoints=https"
        "traefik.http.routers.bambustudio-secure.rule=Host(`${domain}`)"
        "traefik.http.routers.bambustudio-secure.tls=true"
        "traefik.http.services.bambustudio.loadbalancer.server.port=3001"
        "traefik.http.services.bambustudio.loadbalancer.server.scheme=https"
      ];
    };
  };
}
