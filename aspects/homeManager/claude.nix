{
  flake.modules.homeManager.claude = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.claude;

    # The dotfiles repo's Claude Code project slug differs by OS family
    # (verified: -Users-deatrin-src-dotfiles on Darwin, -etc-nixos on NixOS)
    # and its memory has always lived flat at the shared folder's root, not
    # in a per-project subdirectory -- both slugs alias straight to
    # sharedDir so that already-working layout never has to move. Every
    # other project gets its own subdirectory named after its slug; slugs
    # always start with "-" so they can never collide with the dotfiles
    # project's flat *.md filenames living alongside them.
    dotfilesSlugs = ["-Users-deatrin-src-dotfiles" "-etc-nixos"];

    projectsDir = "${config.home.homeDirectory}/.claude/projects";
    sharedDir = "${config.home.homeDirectory}/Sync/claude-memory-dotfiles";
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
        the host it was created on rebuilds (no live file-watcher, by
        design) -- there's no daemon retrying this outside of
        home-manager activation. Requires Syncthing itself to be set up
        and the shared folder paired by hand through its GUI; see
        syncthing-client.nix on NixOS or the launchd agent on Darwin.
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
        # Idempotent, safe to re-run every activation. Two passes:
        #   1. every local project's memory/ gets linked into the shared
        #      folder (dotfiles slugs -> sharedDir itself, everything else
        #      -> sharedDir/<slug>), migrating real content first if the
        #      destination is still empty.
        #   2. every project subdirectory already in the shared folder
        #      (synced in from another host) that has no local project dir
        #      yet gets one created, so its memory is available here even
        #      before this host ever opens that project itself.
        home.activation.claudeMemorySync = lib.hm.dag.entryAfter ["writeBoundary"] ''
          projects_dir=${lib.escapeShellArg projectsDir}
          shared_dir=${lib.escapeShellArg sharedDir}
          dotfiles_slugs=${lib.escapeShellArg (lib.concatStringsSep " " dotfilesSlugs)}

          is_dotfiles_slug() {
            case " $dotfiles_slugs " in
              *" $1 "*) return 0 ;;
              *) return 1 ;;
            esac
          }

          dest_has_content() {
            # Ignore Syncthing's own bookkeeping entries so an already-paired
            # but not-yet-populated folder still counts as empty for this check.
            find "$1" -mindepth 1 -maxdepth 1 \
              ! -name '.stfolder' ! -name '.stversions' ! -name '.stignore' \
              ! -name '.syncthing.*' -print -quit 2>/dev/null
          }

          $DRY_RUN_CMD mkdir -p "$shared_dir"
          $DRY_RUN_CMD mkdir -p "$projects_dir"

          # Pass 1: link every local project's memory/ into the shared folder.
          for project_dir in "$projects_dir"/*/; do
            [ -d "$project_dir" ] || continue
            slug=$(basename "$project_dir")
            memory_dir="''${project_dir%/}/memory"

            if is_dotfiles_slug "$slug"; then
              dest="$shared_dir"
            else
              dest="$shared_dir/$slug"
              $DRY_RUN_CMD mkdir -p "$dest"
            fi

            if [ -L "$memory_dir" ]; then
              : # already a symlink -- idempotent re-run, nothing to do.
            elif [ -d "$memory_dir" ]; then
              if [ -z "$(dest_has_content "$dest")" ]; then
                $VERBOSE_ECHO "claudeMemorySync: migrating $memory_dir into $dest"
                $DRY_RUN_CMD cp -a "$memory_dir/." "$dest/"
                $DRY_RUN_CMD rm -rf "$memory_dir"
                $DRY_RUN_CMD ln -s "$dest" "$memory_dir"
              else
                echo "claudeMemorySync: both $memory_dir and $dest have content -- leaving $memory_dir as a real directory, not symlinking. Resolve manually, then remove $memory_dir so the next activation can symlink it." >&2
              fi
            else
              $DRY_RUN_CMD ln -s "$dest" "$memory_dir"
            fi
          done

          # Pass 2: any project already known in the shared folder (synced in
          # from another host) but never seen locally gets a placeholder
          # project dir + symlink too, so its memory is ready and waiting.
          for dest in "$shared_dir"/-*/; do
            [ -d "$dest" ] || continue
            slug=$(basename "$dest")
            project_dir="$projects_dir/$slug"
            memory_dir="$project_dir/memory"

            $DRY_RUN_CMD mkdir -p "$project_dir"
            if [ -L "$memory_dir" ] || [ -e "$memory_dir" ]; then
              : # already linked (pass 1) or real content left alone above
            else
              $DRY_RUN_CMD ln -s "$dest" "$memory_dir"
            fi
          done
        '';
      })
    ];
  };
}
