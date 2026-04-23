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
    inputs.nix-flatpak.nixosModules.nix-flatpak
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

  # Disable USB autosuspend — prevents keyboard/peripherals from randomly disconnecting
  boot.kernelParams = ["usbcore.autosuspend=-1"];

  networking = {
    hostName = "artemis";
    networkmanager.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  programs.hyprsettings.enable = true;

  # Allow pre-compiled foreign binaries (e.g. Lutris Wine runners) to run
  programs.nix-ld.enable = true;

  # NVIDIA RTX 5080 (Blackwell)
  # open = true is recommended for Turing+ (Blackwell qualifies).
  # If the stable driver doesn't support Blackwell yet, try .beta or switch
  # the overlay to pull from nixpkgs-unstable.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
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

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["deatrin"];
  };

  services.mullvad-vpn.enable = true;

  services.flatpak.overrides = {
    "com.bambulab.BambuStudio".Environment = {
      GTK_THEME = "Adwaita:dark";
    };
  };

  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      "com.usebottles.bottles"
      "com.bambulab.BambuStudio"
    ];
  };
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  zramSwap.enable = true;

  # Wine for Lutris/Battle.net (WoW, etc.)
  # wineWowPackages.staging = both 32+64-bit Wine with staging patches
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    gamescope
    unstable.lutris
    heroic
    discord
    spotify
    rclone
    alsa-scarlett-gui
    input-leap
    unstable.obsidian
    unstable.davinci-resolve
    wineWowPackages.staging
    winetricks
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
