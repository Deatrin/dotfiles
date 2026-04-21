{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.hyprsettings.nixosModules.default
    ./disko-config.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../common/nixos
    ../../common/nixos/users/deatrin
    ../../common/optional/font.nix
    ../../common/optional/podman.nix
    ../../common/optional/reboot-required.nix
    ../../common/optional/xwayland.nix
    ../../common/optional/greetd.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "artemis";
    networkmanager.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  programs.hyprsettings.enable = true;

  # NVIDIA RTX 5080 (Blackwell)
  # open = true is recommended for Turing+ (Blackwell qualifies).
  # If the stable driver doesn't support Blackwell yet, try .beta or switch
  # the overlay to pull from nixpkgs-unstable.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  hardware.xpadneo.enable = true;

  services.mullvad-vpn.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    gamescope
    lutris
    heroic
    discord
    rclone
    alsa-scarlett-gui
    input-leap
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
