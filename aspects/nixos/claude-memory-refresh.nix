# Periodically re-runs the Claude memory sync (pkgs/claude-memory-sync.nix,
# also used by aspects/homeManager/claude.nix's activation step) so a new
# Claude Code project's memory gets migrated into the shared Syncthing
# folder even when nixos-rebuild switch produces no diff -- e.g. after
# just creating a new project directory, which doesn't touch the flake at
# all. nixos-rebuild only restarts a systemd unit when its definition
# actually changed, so a content-only change silently never triggers
# home-manager's own activation. See
# feedback_nixos_rebuild_skips_activation.md for the full story.
#
# Runs the script directly as deatrin rather than restarting
# home-manager-deatrin.service -- restarting that service re-runs every
# activation step and reload hook, including whatever triggers sd-switch
# to touch hyprpanel/hyprpaper on a live desktop session (confirmed on
# artemis: hyprpanel + the wallpaper engine restarted every 2 minutes).
# This way nothing about the timer touches home-manager or any systemd
# user session at all.
{
  flake.modules.nixos.claude-memory-refresh = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.claude-memory-refresh;
  in {
    options.dotfiles.claude-memory-refresh.enable = lib.mkEnableOption ''
      periodically re-running the Claude memory sync directly, to pick up
      new Claude Code project memory without waiting on an unrelated Nix
      change
    '';

    config = lib.mkIf cfg.enable {
      systemd.timers.claude-memory-refresh = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = "2min";
          Unit = "claude-memory-refresh.service";
        };
      };

      systemd.services.claude-memory-refresh = {
        description = "Re-run the Claude memory sync directly (no home-manager/sd-switch involved)";
        serviceConfig = {
          Type = "oneshot";
          User = "deatrin";
          Group = "users";
          Environment = ["HOME=/home/deatrin"];
          ExecStart = "${pkgs.claude-memory-sync}/bin/claude-memory-sync";
        };
      };
    };
  };
}
