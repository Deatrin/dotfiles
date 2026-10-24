{
  flake.modules.nixos.xwayland = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.xwayland;
  in {
    options.dotfiles.xwayland.enable = lib.mkEnableOption "Hyprland with XWayland and Thunar";

    config = lib.mkIf cfg.enable {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
      };

      # hyprlock is configured in home-manager, which can't create its PAM
      # service; without this it falls back to /etc/pam.d/su.
      security.pam.services.hyprlock = {};

      # Realtime scheduling for pipewire/wireplumber (enabled by
      # programs.hyprland via graphical-desktop); without it they log
      # "RTKit error: ServiceUnknown" and run at normal priority.
      security.rtkit.enable = true;

      programs.thunar = {
        enable = true;
        plugins = with pkgs; [thunar-archive-plugin thunar-volman];
      };
    };
  };
}
