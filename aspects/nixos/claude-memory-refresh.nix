# Periodically restarts home-manager-deatrin.service so the claudeMemorySync
# home-manager activation script (aspects/homeManager/claude.nix) re-runs
# even when nixos-rebuild switch produces no diff -- e.g. after creating a
# new Claude Code project directory, which doesn't touch the flake at all.
# nixos-rebuild only restarts a systemd unit when its definition actually
# changed, so a content-only change silently never triggers the migration.
# See feedback_nixos_rebuild_skips_activation.md for the full story.
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
      periodic home-manager-deatrin.service restarts to pick up new Claude
      Code project memory without waiting on an unrelated Nix change
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
        description = "Re-run claudeMemorySync by restarting home-manager-deatrin.service";
        after = ["home-manager-deatrin.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart home-manager-deatrin.service";
        };
      };
    };
  };
}
