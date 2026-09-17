{
  flake.modules.homeManager.claude = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.claude;

    # Claude Code's project slug is its working directory with every "/"
    # replaced by "-" (verified: this repo's own project dir on tynan is
    # ~/.claude/projects/-Users-deatrin-src-dotfiles/). Mirrors the Linux/
    # Darwin branch in home-manager/common/features/cli/nh.nix, but simpler:
    # both hosts this applies to run the same user, so nh.nix's
    # ajennex-specific branch and generic-username fallback don't apply --
    # duplicating this shorter form beats dragging those irrelevant branches
    # into a shared helper for two call sites with different needs.
    repoPath =
      if pkgs.stdenv.isLinux
      then "/etc/nixos"
      else "/Users/${config.home.username}/src/dotfiles";
    projectSlug = builtins.replaceStrings ["/"] ["-"] repoPath;

    memoryDir = "${config.home.homeDirectory}/.claude/projects/${projectSlug}/memory";
    sharedDir = "${config.home.homeDirectory}/Sync/claude-memory-dotfiles";
  in {
    options.dotfiles.claude = {
      enable = lib.mkEnableOption "Claude Code CLI";

      memorySync.enable = lib.mkEnableOption ''
        syncing this repo's Claude Code project memory (~/.claude/projects/<slug>/memory)
        across hosts by symlinking it into a Syncthing-shared folder
        (~/Sync/claude-memory-dotfiles). Only the memory/ subdirectory is
        shared -- session transcripts stay local. Requires Syncthing itself
        to be set up and the shared folder paired by hand through its GUI;
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
        # Idempotent, safe to re-run every activation:
        #   memory/ already a symlink            -> no-op
        #   memory/ is a real dir, shared empty   -> migrate contents, then symlink
        #   memory/ is a real dir, shared has too -> leave alone, warn (manual merge)
        #   neither exists yet                    -> just symlink
        home.activation.claudeMemorySync = lib.hm.dag.entryAfter ["writeBoundary"] ''
          memory_dir=${lib.escapeShellArg memoryDir}
          shared_dir=${lib.escapeShellArg sharedDir}
          project_dir=$(dirname "$memory_dir")

          $DRY_RUN_CMD mkdir -p "$shared_dir"
          $DRY_RUN_CMD mkdir -p "$project_dir"

          if [ -L "$memory_dir" ]; then
            : # already a symlink -- idempotent re-run, nothing to do.
          elif [ -d "$memory_dir" ]; then
            # Ignore Syncthing's own bookkeeping entries so an already-paired
            # but not-yet-populated folder still counts as empty for this check.
            shared_has_content=$(find "$shared_dir" -mindepth 1 -maxdepth 1 \
              ! -name '.stfolder' ! -name '.stversions' ! -name '.stignore' \
              ! -name '.syncthing.*' -print -quit 2>/dev/null)
            if [ -z "$shared_has_content" ]; then
              $VERBOSE_ECHO "claudeMemorySync: migrating $memory_dir into $shared_dir"
              $DRY_RUN_CMD cp -a "$memory_dir/." "$shared_dir/"
              $DRY_RUN_CMD rm -rf "$memory_dir"
              $DRY_RUN_CMD ln -s "$shared_dir" "$memory_dir"
            else
              echo "claudeMemorySync: both $memory_dir and $shared_dir have content -- leaving $memory_dir as a real directory, not symlinking. Resolve manually, then remove $memory_dir so the next activation can symlink it." >&2
            fi
          else
            # Neither exists yet -- plain first-time symlink creation.
            $DRY_RUN_CMD ln -s "$shared_dir" "$memory_dir"
          fi
        '';
      })
    ];
  };
}
