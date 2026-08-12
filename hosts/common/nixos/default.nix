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
      ./auto-upgrade.nix
      ./locale.nix
      ./nfs.nix
      ./nix.nix
      ./openssh.nix
      ./systemd-initrd.nix
      ./tailscale.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

  nixpkgs = {
    # You can add overlays here
    # overlays = builtins.attrValues outputs.overlays;
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.plex

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # pnpm-10.29.2 CVEs are in package installation behavior, not build artifacts
      # hyprpanel pulls it in as a build dep; safe to permit until nixpkgs bumps it
      permittedInsecurePackages = ["pnpm-10.29.2"];
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
    pkgs.unstable.nh
    pkgs.unstable.cifs-utils
    pkgs.unstable.alacritty
    pkgs.unstable.koreader
  ];
  programs.ssh.startAgent = false;

  services.upower.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
}
