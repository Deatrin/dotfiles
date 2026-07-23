{
  flake.modules.homeManager.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.desktop;
  in {
    options.dotfiles.desktop.enable = lib.mkEnableOption "Hyprland desktop environment";

    imports = [
      ../../home-manager/common/features/desktop/hypridle.nix
      ../../home-manager/common/features/desktop/hyprland.nix
      ../../home-manager/common/features/desktop/hyprlock.nix
      ../../home-manager/common/features/desktop/hyprpanel.nix
      ../../home-manager/common/features/desktop/hyprpaper.nix
      ../../home-manager/common/features/desktop/rofi.nix
      ../../home-manager/common/features/desktop/theme.nix
    ];

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        brave
        devpod-desktop
        vivaldi
        wlopm
        wttrbar
      ];
    };
  };
}
