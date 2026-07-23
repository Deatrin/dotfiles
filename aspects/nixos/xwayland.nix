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

      programs.thunar = {
        enable = true;
        plugins = with pkgs; [thunar-archive-plugin thunar-volman];
      };
    };
  };
}
