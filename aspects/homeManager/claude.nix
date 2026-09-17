{
  flake.modules.homeManager.claude = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.claude;
  in {
    options.dotfiles.claude = {
      enable = lib.mkEnableOption "Claude Code CLI";

      memorySync.enable = lib.mkEnableOption ''
        syncing ALL Claude Code project memory (~/.claude/projects/*/memory)
        across hosts by symlinking each project's memory/ into a
        Syncthing-shared folder (~/Sync/claude-memory-dotfiles) -- the
        dotfiles repo's memory lives flat at that folder's root (legacy
        layout, unchanged), every other project gets its own subdirectory
        there named after its project slug. Only memory/ is ever shared --
        session transcripts stay local. A project only starts syncing after
        this migrate/symlink step actually runs; on NixOS hosts, pair with
        dotfiles.claude-memory-refresh so that happens periodically without
        waiting on an unrelated Nix rebuild. Requires Syncthing itself to
        be set up and the shared folder paired by hand through its GUI;
        see syncthing-client.nix on NixOS or the launchd agent on Darwin.
      '';
    };

    config = lib.mkMerge [
      (lib.mkIf cfg.enable {
        programs.claude-code = {
          enable = true;
          package = pkgs.unstable.claude-code;
        };
      })

      (lib.mkIf cfg.memorySync.enable {
        # The actual migrate/symlink logic lives in pkgs/claude-memory-sync.nix
        # (shared with aspects/nixos/claude-memory-refresh.nix's periodic
        # timer) so both call sites run the exact same script instead of
        # duplicating it or one triggering the other via a service restart.
        home.activation.claudeMemorySync = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${pkgs.claude-memory-sync}/bin/claude-memory-sync
        '';
      })
    ];
  };
}
