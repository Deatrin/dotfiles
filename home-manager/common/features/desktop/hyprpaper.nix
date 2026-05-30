{...}: let
  wallpaper = ./../../../../wallpapers/stary_firewatch.png;
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["${wallpaper}"];
      wallpaper = [",${wallpaper}"];
    };
  };
}
