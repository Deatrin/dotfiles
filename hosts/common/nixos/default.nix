# This file (and the global directory) holds config used on all hosts
{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      inputs.opnix.nixosModules.default
      inputs.nix-topology.nixosModules.default
      ./locale.nix
      ./nfs.nix
      ./nix.nix
      ./openssh.nix
      ./systemd-initrd.nix
      ./tailscale.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  home-manager = {
    # home-manager reuses this host's pkgs (overlays + config below) instead
    # of building its own nixpkgs instance, and installs home.packages into
    # /etc/profiles/per-user/<user> as part of the system closure.
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

  nixpkgs = {
    # Every overlay this flake exports — shared with home-manager via
    # useGlobalPkgs, so system and home config see the same pkgs.
    overlays = builtins.attrValues outputs.overlays;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  #environment.enableAllTerminfo = true;
  hardware.enableRedistributableFirmware = true;

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  # Enable printing changes on nix build etc with nvd
  #system.activationScripts.report-changes = ''
  #  PATH=$PATH:${
  #    lib.makeBinPath [
  #      pkgs.nvd
  #      pkgs.nix
  #    ]
  #  }
  #  nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  #'';

  # always install these for all users on nixos systems
  environment.systemPackages = [
    pkgs.git
    pkgs.unstable.antigravity-cli
    pkgs.htop
    pkgs.toybox
    pkgs.pciutils
    pkgs.unstable.cifs-utils
    pkgs.unstable.alacritty
    pkgs.unstable.koreader
  ];
  programs.ssh.startAgent = false;

  # System-wide GC via `nh clean all` (system generations + every user's
  # profiles). home-manager's programs.nh.clean only runs `nh clean user`, so
  # it can't replace this. NH_FLAKE stays set per-user by home-manager.
  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };

  services.upower.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
}
