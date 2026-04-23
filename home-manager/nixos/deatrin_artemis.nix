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
    inputs.nix-ld-vscode.nixosModules.default
  ];

  # NVIDIA RTX 5080 — Hyprland env vars for Wayland/NVIDIA.
  # Add to the common env list via mkAfter so they don't clobber existing vars.
  # No battery on a desktop
  programs.hyprpanel.settings.bar.layouts = {
    "0" = {
      left = ["dashboard" "workspaces" "windowtitle"];
      middle = ["clock"];
      right = ["volume" "network" "bluetooth" "systray" "notifications"];
    };
  };

  wayland.windowManager.hyprland.settings = {
    env = lib.mkAfter [
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "NVD_BACKEND,direct"
    ];

    # 3-monitor layout — confirm DP-X names via `hyprctl monitors` after first boot.
    # Positions: left(2560x1440) | ultrawide center(5120x2160) | portrait right(1920x1080)
    monitor = [
      "DP-5,2560x1440@165,0x0,1"
      "DP-3,5120x2160@165,2560x0,1"
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
