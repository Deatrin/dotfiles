{
  config,
  lib,
  pkgs,
  ...
}: {
  # ── Networks ──────────────────────────────────────────────────────────────────
  networks = {
    wireless = {
      name = "Wireless / IoT";
      cidrv4 = "10.1.1.0/24";
    };
    secured-wired = {
      name = "Secured Wired";
      cidrv4 = "10.1.10.0/24";
    };
    server-mgmt = {
      name = "Server MGMT";
      cidrv4 = "10.1.20.0/24";
    };
    homelab = {
      name = "HomeLab";
      cidrv4 = "10.1.30.0/24";
    };
    dmz = {
      name = "DMZ";
      cidrv4 = "10.1.40.0/24";
    };
    switch-mgmt = {
      name = "Switch MGMT";
      cidrv4 = "10.1.150.0/24";
    };
    tailscale = {
      name = "Tailscale VPN";
      cidrv4 = "100.64.0.0/10";
    };
    wan = {
      name = "Internet";
      cidrv4 = "0.0.0.0/0";
    };
  };

  # ── Nodes ─────────────────────────────────────────────────────────────────────
  nodes = {
    # ── Internet ──────────────────────────────────────────────────────────────
    internet = {
      deviceType = "device";
      hardware.info = "Internet";
      interfaces.isp = {
        network = "wan";
      };
    };

    # ── UniFi Gateway / Router ────────────────────────────────────────────────
    # L3 router for all VLANs — reachable at .1 on every subnet
    # Also hosts the UniFi controller UI
    router = {
      deviceType = "device";
      hardware.info = "UniFi Gateway";
      interfaces = {
        wan = {
          network = "wan";
          physicalConnections = [
            {
              node = "internet";
              interface = "isp";
            }
          ];
        };
        # Trunked physical downlink to switch; VLANs below are logical sub-interfaces
        trunk = {
          network = "homelab";
          physicalConnections = [
            {
              node = "switch-main";
              interface = "uplink";
            }
          ];
        };
        vlan-wireless = {
          network = "wireless";
          virtual = true;
        };
        vlan-secured-wired = {
          network = "secured-wired";
          virtual = true;
        };
        vlan-server-mgmt = {
          network = "server-mgmt";
          virtual = true;
        };
        vlan-dmz = {
          network = "dmz";
          virtual = true;
        };
        vlan-switch-mgmt = {
          network = "switch-mgmt";
          virtual = true;
        };
      };
    };

    # ── UniFi Switch ──────────────────────────────────────────────────────────
    switch-main = {
      deviceType = "device";
      hardware.info = "UniFi Switch";
      interfaces = {
        uplink = {
          network = "homelab";
        };
        mgmt = {
          network = "switch-mgmt";
        };
        # HomeLab VLAN
        port-nauvoo = {
          network = "homelab";
          physicalConnections = [
            {
              node = "nauvoo";
              interface = "enp38s0";
            }
          ];
        };
        # Secured Wired VLAN
        port-synology = {
          network = "secured-wired";
          physicalConnections = [
            {
              node = "synology";
              interface = "eth0";
            }
          ];
        };
        port-tycho-wired = {
          network = "secured-wired";
          physicalConnections = [
            {
              node = "tycho";
              interface = "enp0s31f6";
            }
          ];
        };
        # Server MGMT VLAN
        port-truenas = {
          network = "server-mgmt";
          physicalConnections = [
            {
              node = "truenas";
              interface = "eth0";
            }
          ];
        };
      };
    };

    # ── Synology NAS — secured wired, hot storage ─────────────────────────────
    # NFS export: 10.1.10.5:/volume1/Roci/Media_Storage → nauvoo /storage/media
    synology = {
      deviceType = "device";
      hardware.info = "Synology NAS — 10.1.10.5";
      interfaces = {
        eth0 = {
          network = "secured-wired";
        };
      };
    };

    # ── TrueNAS — server MGMT, cold storage / disaster recovery ──────────────
    # Only booted when recovering from a serious failure
    # Receives nightly rsync backups from nauvoo (truenas_admin@10.1.20.45)
    truenas = {
      deviceType = "device";
      hardware.info = "TrueNAS — 10.1.20.45";
      interfaces = {
        eth0 = {
          network = "server-mgmt";
        };
      };
    };

    # ── nauvoo — supplemental (interfaces auto-extracted from NixOS config) ───
    # Physical server: x86_64, NVIDIA GPU, Podman Quadlet, 10.1.30.100
    # Tailscale exit node + subnet router for 10.1.0.0/16
    nauvoo = {
      interfaces = {
        tailscale0 = {
          network = "tailscale";
          virtual = true;
        };
      };
    };

    # ── tycho — supplemental (interfaces auto-extracted from NixOS config) ────
    # Lenovo T14 G3 laptop, NixOS, Hyprland
    # Primary: wifi (wlp0s20f3) → wireless VLAN; wired (enp0s31f6) → secured-wired, normally unplugged
    tycho = {
      interfaces = {
        wlp0s20f3 = {
          network = "wireless";
          type = "wireless";
        };
        # Wired — normally unplugged at home, connects to secured-wired VLAN when used
        enp0s31f6 = {
          network = "secured-wired";
        };
        tailscale0 = {
          network = "tailscale";
          virtual = true;
        };
      };
    };

    # ── tynan — M1 Pro MacBook (aarch64-darwin) ───────────────────────────────
    # Primary daily driver; Darwin auto-extraction not available
    tynan = {
      deviceType = "device";
      hardware.info = "M1 Pro MacBook (tynan) — aarch64-darwin";
      interfaces = {
        wifi = {
          network = "wireless";
          type = "wireless";
        };
        tailscale0 = {
          network = "tailscale";
          virtual = true;
        };
      };
    };

    # TODO: add donnager (iMac Pro, x86_64-darwin, user ajennex) when it moves
    # back into active use — currently inactive
  };
}
