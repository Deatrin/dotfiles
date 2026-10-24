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

          # Attached panels copy the bar's background_opacity (0 here), so
          # float them; floating panels use transparency_mode (soft = 80%).
          panel = {
            transparency_mode = "soft";
            control_center_placement = "floating";
            session_placement = "floating";
          };
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
          # Transparent bar with each widget on its own pill (hyprpanel's old look)
          background_opacity = 0.0;
          compositor_blur = false;
          shadow = false;
          capsule = true;
          # Full-width bar: start/end widgets sit near the screen sides
          margin_ends = 0;
          padding = 8;
          start = ["control-center" "workspaces" "active-window"];
          center = ["clock"];
          end = ["volume" "brightness" "battery" "network" "bluetooth" "tray" "notifications"];
        };

        widget.clock.format = "{:%A %H:%M}";
      };
    };
  };
}
