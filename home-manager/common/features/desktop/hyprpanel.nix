{pkgs, ...}: {
  home.packages = with pkgs; [
    brightnessctl
    pavucontrol
  ];

  programs.hyprpanel = {
    enable = true;
    systemd.enable = false;

    settings = {
      # Bar layout — mirrors existing waybar setup
      bar.layouts = {
        "0" = {
          left = ["dashboard" "workspaces" "windowtitle"];
          middle = ["clock"];
          right = ["volume" "backlight" "battery" "network" "bluetooth" "systray" "notifications"];
        };
      };

      bar.workspaces = {
        show_icons = true;
        show_numbered = false;
        workspaces = 5;
      };

      bar.launcher.autoDetectIcon = true;

      bar.clock = {
        format = "%A %H:%M";
        showIcon = false;
      };

      bar.volume = {
        label = true;
        scrollStep = 5;
      };

      bar.backlight = {
        label = true;
        scrollStep = 5;
      };

      bar.battery = {
        label = true;
        showIcon = true;
      };

      bar.network.label = true;

      # Tokyo Night Dark theme
      theme.bar.transparent = true;
      theme.bar.floating = true;

      theme.font = {
        name = "JetBrainsMono Nerd Font";
        size = "12px";
      };

      theme.bar.buttons = {
        # Background colors
        "background" = "#1a1b26";
        "hover" = "#24283b";
        "border" = "#3b4261";
        "text" = "#c0caf5";

        # Workspaces
        workspaces = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "active" = "#bb9af7";
          "available" = "#7aa2f7";
          "occupied" = "#7dcfff";
        };

        # Volume
        volume = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "icon" = "#7aa2f7";
          "text" = "#c0caf5";
        };

        # Backlight
        backlight = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "icon" = "#e0af68";
          "text" = "#c0caf5";
        };

        # Battery
        battery = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "icon" = "#9ece6a";
          "text" = "#c0caf5";
          "charging" = "#9ece6a";
          "medium" = "#e0af68";
          "low" = "#f7768e";
        };

        # Network
        network = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "icon" = "#7dcfff";
          "text" = "#c0caf5";
        };

        # Bluetooth
        bluetooth = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "icon" = "#bb9af7";
          "text" = "#c0caf5";
        };

        # Clock
        clock = {
          "background" = "#1a1b26";
          "hover" = "#24283b";
          "icon" = "#c0caf5";
          "text" = "#c0caf5";
        };
      };

      # Notification popup styling
      theme.notification = {
        "background" = "#1a1b26";
        "border" = "#3b4261";
        "text" = "#c0caf5";
        "labelicon" = "#bb9af7";
      };
    };
  };
}
