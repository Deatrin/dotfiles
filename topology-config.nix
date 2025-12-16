{
  config,
  lib,
  pkgs,
  ...
}: {
  # Network definitions
  networks = {
    home-lan = {
      name = "Home LAN";
      cidrv4 = "10.1.30.0/24";
    };
    storage-net = {
      name = "Storage Network";
      cidrv4 = "10.1.10.0/24";
    };
    wan = {
      name = "Internet";
      cidrv4 = "0.0.0.0/0";
    };
  };

  # External devices and Darwin hosts
  nodes = {
    # Internet connection
    internet = {
      deviceType = "device";
      hardware.info = "Internet";
      interfaces.isp = {
        network = "wan";
      };
    };

    # Main router
    router = {
      deviceType = "device";
      hardware.info = "Main Home Router (10.1.30.1)";
      interfaces = {
        wan = {
          network = "wan";
          physicalConnections = [
            {node = "internet"; interface = "isp";}
          ];
        };
        lan = {
          network = "home-lan";
          physicalConnections = [
            {node = "switch-main"; interface = "uplink";}
          ];
        };
      };
    };

    # Main network switch
    switch-main = {
      deviceType = "device";
      hardware.info = "Main Network Switch";
      interfaces = {
        uplink = {
          network = "home-lan";
        };
        port1 = {
          network = "home-lan";
          physicalConnections = [
            {node = "nauvoo"; interface = "enp38s0";}
          ];
        };
      };
    };

    # NAS storage server
    nas-storage = {
      deviceType = "device";
      hardware.info = "Synology NAS (10.1.10.5)";
      interfaces = {
        eth0 = {
          network = "storage-net";
        };
        nfs = {
          virtual = true;
          network = "storage-net";
        };
      };
    };

    # Darwin host (manual definition - auto-extraction only works for NixOS)
    # Only including tynan as it's the primary daily-use Darwin machine
    tynan = {
      deviceType = "device";
      hardware.info = "M1 Pro MacBook (tynan) - aarch64-darwin";
      interfaces = {
        wifi = {
          network = "home-lan";
          type = "wireless";
        };
      };
    };
  };
}
