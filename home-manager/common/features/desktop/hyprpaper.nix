{
  config,
  lib,
  ...
}: let
  wallpaper = ./../../../../wallpapers/stary_firewatch.png;
in {
  config = lib.mkIf config.dotfiles.desktop.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = ["${wallpaper}"];
        wallpaper = [",${wallpaper}"];
      };
    };
  };
}
