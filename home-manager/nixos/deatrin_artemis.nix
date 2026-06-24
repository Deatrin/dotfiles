{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  wallpaper = ../../wallpapers/stary_firewatch.png;
in {
  imports = [
    ../common/global
    ../common/features/cli/claude.nix
    ../common/features/cli/ghostty.nix
    ../common/features/cli/opnix_personal.nix
    ../common/features/dev
    ../common/features/desktop
    inputs.nix-ld-vscode.nixosModules.default
  ];

  # NVIDIA RTX 5080 — Hyprland env vars for Wayland/NVIDIA.
  # Add to the common env list via mkAfter so they don't clobber existing vars.
  # No battery on a desktop
  services.hyprpaper.settings.wallpaper = lib.mkForce [
    "DP-3,${wallpaper}"
    "DP-4,${wallpaper}"
    "DP-5,${wallpaper}"
  ];

  # NVIDIA enumerates monitors slowly — poll until all 3 are registered before hyprpaper starts.
  # Without this, the systemd service races ahead and sees 0 monitors → "no target" for all.
  # NOTE: home-manager systemd uses Service (not serviceConfig) for [Service] section entries.
  systemd.user.services.hyprpaper.Service.ExecStartPre = let
    hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  in "/bin/sh -c 'n=0; while [ $n -lt 120 ] && [ \"$(${hyprctl} monitors 2>/dev/null | grep -c ^Monitor)\" -lt 3 ]; do sleep 0.5; n=$((n+1)); done'";

  # Apply wallpapers via IPC on every start/restart (not just Hyprland's initial exec-once).
  # sd-switch restarts hyprpaper when its unit changes (e.g. nixpkgs bump); without this the
  # IPC assignment for DP-4/DP-5 never re-runs and those monitors stay blank.
  systemd.user.services.hyprpaper.Service.ExecStartPost = let
    hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
    w = "${wallpaper}";
  in "/bin/sh -c 'sleep 1; ${hyprctl} hyprpaper wallpaper \"DP-3,${w}\"; ${hyprctl} hyprpaper wallpaper \"DP-4,${w}\"; ${hyprctl} hyprpaper wallpaper \"DP-5,${w}\"'";

  programs.hyprpanel.settings.bar.layouts = lib.mkForce {
    "0" = {
      left = ["dashboard" "workspaces" "windowtitle" "media"];
      middle = ["clock"];
      right = ["volume" "network" "bluetooth" "systray" "notifications"];
    };
    "1" = {
      left = ["dashboard" "workspaces" "windowtitle" "media"];
      middle = ["clock"];
      right = ["volume" "network" "bluetooth" "systray" "notifications"];
    };
    "2" = {
      left = ["dashboard" "workspaces" "windowtitle" "media"];
      middle = ["clock"];
      right = ["volume" "network" "bluetooth" "systray" "notifications"];
    };
  };

  # Desktop has no backlight — drop brightnessctl listener, keep lock + dpms listeners.
  services.hypridle.settings.listener = lib.mkForce [
    {
      timeout = 300;
      on-timeout = "loginctl lock-session";
    }
    {
      timeout = 330;
      on-timeout = "wlopm --off '*'";
      on-resume = "wlopm --on '*'";
    }
  ];

  wayland.windowManager.hyprland.settings = {
    env = lib.mkAfter [
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "NVD_BACKEND,direct"
    ];

    # 3-monitor layout — confirm DP-X names via `hyprctl monitors` after first boot.
    # Positions: left(2560x1440) | ultrawide center(5120x2160, HDR) | portrait right(1920x1080)
    # To disable HDR on DP-3, swap back to: "DP-3,5120x2160@165,2560x0,1"
    monitor = [
      "DP-5,2560x1440@165,0x0,1"
      "DP-3,5120x2160@165,2560x0,1,bitdepth,10,cm,hdr"
      "DP-4,1920x1080@60,7680x0,1,transform,1"
    ];

    # Cursor glitches on NVIDIA — disable hardware cursors if needed.
    cursor.no_hardware_cursors = true;

  };

  # rclone bisync timers — run after rclone config OAuth flow (run once manually):
  #   rclone config  (authenticate dropbox and gdrive remotes)
  systemd.user.services = {
    rclone-dropbox = {
      Unit.Description = "Dropbox bisync";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone bisync dropbox: %h/Dropbox --create-empty-src-dirs --resilient";
      };
    };
    rclone-gdrive = {
      Unit.Description = "Google Drive bisync";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone bisync gdrive: %h/GoogleDrive --create-empty-src-dirs --resilient";
      };
    };
  };

  systemd.user.timers = {
    rclone-dropbox = {
      Unit.Description = "Dropbox bisync timer";
      Timer = {
        OnBootSec = "2min";
        OnUnitActiveSec = "1h";
      };
      Install.WantedBy = ["timers.target"];
    };
    rclone-gdrive = {
      Unit.Description = "Google Drive bisync timer";
      Timer = {
        OnBootSec = "2min";
        OnUnitActiveSec = "1h";
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.11";
    packages = with pkgs; [
      yubioath-flutter
      yubikey-manager
    ];
  };
}
