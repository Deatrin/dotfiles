{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.noctalia.homeModules.default];

  config = lib.mkIf config.dotfiles.desktop.enable {
    home.packages = with pkgs; [
      brightnessctl
      pavucontrol
    ];

    programs.noctalia = {
      enable = true;
      package = pkgs.unstable.noctalia;
      systemd.enable = true;

      settings = {
        shell = {
          font_family = "JetBrainsMono Nerd Font";
          # Apps started from the launcher would otherwise die whenever the
          # noctalia user service restarts (e.g. on a config change).
          launch_apps_as_systemd_services = true;
          # clipman already keeps clipboard history (see hyprland.nix exec-once).
          clipboard_enabled = false;
        };

        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Tokyo-Night";
        };

        # hyprpaper owns wallpapers, hyprlock owns locking (via hypridle's
        # loginctl lock-session — noctalia's lockscreen would also answer it).
        wallpaper.enabled = false;
        lockscreen.enabled = false;

        bar.main = {
          position = "top";
          start = ["control-center" "workspaces" "active-window"];
          center = ["clock"];
          end = ["volume" "brightness" "battery" "network" "bluetooth" "tray" "notifications"];
        };

        widget.clock.format = "{:%A %H:%M}";
      };
    };
  };
}
