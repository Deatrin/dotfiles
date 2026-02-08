{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../common/global
    ../common/features/cli/claude.nix
    ../common/features/cli/ghostty.nix
    ../common/features/cli/opnix_personal.nix
    ../common/features/dev
    ../common/features/desktop
    ../common/features/kubernetes
  ];

  # M2 MacBook Air: 2560x1664 display
  wayland.windowManager.hyprland.settings.monitor = lib.mkForce "eDP-1, 2560x1664@60, 0x0, 1.6";

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.11";
    packages = with pkgs; [
      _1password-gui
      _1password-cli
      yubioath-flutter
      yubikey-manager
    ];
  };
}
