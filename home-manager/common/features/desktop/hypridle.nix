{
  config,
  lib,
  pkgs,
  ...
}: let
  # When monitors re-hotplug on wake, Hyprland can kill every client's Wayland
  # connection with a protocol error. hyprlock then keeps running without a
  # surface, so `pidof hyprlock` blocks every relaunch and the session stays
  # locked with no locker. Watch for libwayland's fatal-error line, kill the
  # orphaned hyprlock and start a new one (allow_session_lock_restore lets it
  # take over the lock). Any other exit, including a crash, is left alone.
  hyprlock-guard = pkgs.writeShellApplication {
    name = "hyprlock-guard";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      # e.g. "wl_display#1: error 0: invalid object 26"
      fatal='^[[:alnum:]_]+[#@][0-9]+: error [0-9]+:'

      for attempt in 1 2 3 4 5; do
        exec {out}< <(exec ${lib.getExe config.programs.hyprlock.package} "$@" 2>&1)
        pid=$!
        lost=0
        while IFS= read -r line <&"$out"; do
          printf '%s\n' "$line"
          if [[ $lost == 0 && $line =~ $fatal ]]; then
            echo "hyprlock-guard: hyprlock lost its Wayland connection, restarting it (attempt $attempt)" >&2
            lost=1
            kill -9 "$pid" 2>/dev/null || true
          fi
        done
        exec {out}<&-
        wait "$pid" 2>/dev/null || true

        [[ $lost == 1 ]] || exit 0
        sleep 2
      done

      echo "hyprlock-guard: giving up after $attempt restarts" >&2
      exit 1
    '';
  };
in {
  config = lib.mkIf config.dotfiles.desktop.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || ${lib.getExe hyprlock-guard}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "wlopm --on '*'";
        };

        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "wlopm --off '*'";
            on-resume = "wlopm --on '*'";
          }
          # {
          #   timeout = 1800;
          #   on-timeout = "systemctl suspend";
          # }
        ];
      };
    };
  };
}
