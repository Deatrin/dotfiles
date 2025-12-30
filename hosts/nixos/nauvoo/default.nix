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
    ../../common/containers
    ../../common/nixos
    ../../common/nixos/users/deatrin
    ../../common/optional/docker.nix
    ../../common/optional/plex.nix
    ../../common/optional/reboot-required.nix
    ../../common/optional/salt.nix
    ../../common/optional/vscode-server.nix
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
    nameservers = ["10.1.30.1"];
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
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = ["nvidia"];

  fileSystems."/media" = {
    device = "10.1.10.5:/volume1/Roci/Media_Storage";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
