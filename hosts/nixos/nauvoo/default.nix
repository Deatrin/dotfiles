{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../common/nixos
    ../../common/nixos/users/deatrin
    ./backup.nix
    ./containers.nix
  ];

  dotfiles = {
    jellyfin.enable = true;
    plex.enable = true;
    reboot-required.enable = true;
    salt.enable = true;
    vscode-server.enable = true;
    code-server.enable = true;
    forgejo-runner.enable = true;
    attic-server.enable = true;
    attic-client.enable = true;
  };

  # Fallback auth layer for code-server, in case a Tailscale peer reaches it
  # directly rather than through Traefik. Generate with:
  #   echo -n 'yourpassword' | nix run nixpkgs#libargon2 -- "$(head -c 20 /dev/random | base64)" -e
  services.code-server.hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$bzUwTjA0d3pWaW1uZHBtRy9DZXhHbmo0ZTZVPQ$nZJF3QZyMQQy3/NnI76AX4IchpgARmaG8j0GtX8s2+E";

  # Dedicated key for remote dev (tablet SSH client + headless commit signing) — see
  # home-manager/nixos/deatrin_nauvoo.nix for the matching signing setup.
  users.users.deatrin.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7UrapQ7YzEmhaI1pMWaqKMY8tAsX1z4a858Gn4/v+V nauvoo-remote"
  ];

  networking = {
    hostName = "nauvoo";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    interfaces.enp38s0.ipv4.addresses = [
      {
        address = "10.1.30.100";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.1.30.1";
    nameservers = ["10.1.30.100" "10.1.30.1"];
  };

  # Open TFTP port for netboot.xyz PXE booting, plus qBittorrent's peer port
  # (see aspects/nixos/containers/seedbox.nix publishPorts)
  networking.firewall.allowedTCPPorts = [38888];
  networking.firewall.allowedUDPPorts = [69 38888];

  # Change up the ssh port to make room for forgejo
  services.openssh = {
    ports = [2222];
    openFirewall = true; # Explicitly ensure firewall allows SSH on custom port
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = false; # RTX 2080 Turing only has beta support in open driver — proprietary is more stable

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = ["nvidia"];

  # Tailscale exit node + subnet routing
  services.tailscale-autoconnect.exitNode = true;
  services.tailscale-autoconnect.advertiseRoutes = ["10.1.0.0/16"];

  services.dotfiles-sync = {
    enable = true;
    flakeAttr = "nauvoo";
  };

  # Auto-reboot if kernel freezes (sp5100-tco hardware watchdog)
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "10m";
  };

  # Enable IP forwarding for Tailscale exit node
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # RTL8125B 2.5GbE (r8169 driver) stability fixes.
  # (2026-06-13) PCIe ASPM puts the NIC into a low-power state it can't wake from → TX queue freeze.
  # (2026-06-14) Kernel 6.18 r8169 enters a periodic admin-down/up reset loop every ~414s after
  #              heavy veth churn (e.g. podman auto-update). 18 cycles → hard lockup. Pin to 6.12.
  boot.kernelParams = ["pcie_aspm=off"];
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Disable Energy Efficient Ethernet (EEE) on RTL8125B at boot.
  # EEE's LPI wake-up handling in r8169 6.18 triggers the periodic reset cycle under load.
  # Disabling it here ensures the setting survives across link events, not just initial boot.
  systemd.services.disable-eee-enp38s0 = {
    description = "Disable EEE on enp38s0 (RTL8125B r8169)";
    after = ["sys-subsystem-net-devices-enp38s0.device"];
    bindsTo = ["sys-subsystem-net-devices-enp38s0.device"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool --set-eee enp38s0 eee off";
    };
  };

  environment.systemPackages = [pkgs.ethtool];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
