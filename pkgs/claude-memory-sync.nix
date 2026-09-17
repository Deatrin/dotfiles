# Migrates each local Claude Code project's memory/ into the shared
# Syncthing folder (~/Sync/claude-memory-dotfiles) and symlinks it back,
# plus creates a placeholder for any project already synced in from
# another host. See aspects/homeManager/claude.nix (calls this as a
# home.activation step) and aspects/nixos/claude-memory-refresh.nix (calls
# it directly from a systemd timer, bypassing home-manager activation
# entirely so it never touches sd-switch/hyprpanel/hyprpaper on a live
# desktop session).
#
# Paths are read from $HOME at runtime rather than baked in at eval time,
# so the exact same binary works correctly under both call sites.
{
  writeShellApplication,
  coreutils,
  findutils,
}:
writeShellApplication {
  name = "claude-memory-sync";
  runtimeInputs = [coreutils findutils];
  text = ''
    projects_dir="$HOME/.claude/projects"
    shared_dir="$HOME/Sync/claude-memory-dotfiles"

    # The dotfiles repo's Claude Code project slug differs by OS family
    # (-Users-deatrin-src-dotfiles on Darwin, -etc-nixos on NixOS) and its
    # memory has always lived flat at the shared folder's root, not in a
    # per-project subdirectory -- both slugs alias straight to shared_dir
    # so that already-working layout never has to move. Every other
    # project gets its own subdirectory named after its slug; slugs always
    # start with "-" so they can never collide with the dotfiles project's
    # flat *.md filenames living alongside them.
    dotfiles_slugs="-Users-deatrin-src-dotfiles -etc-nixos"

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

    mkdir -p "$shared_dir"
    mkdir -p "$projects_dir"

    # Pass 1: link every local project's memory/ into the shared folder.
    for project_dir in "$projects_dir"/*/; do
      [ -d "$project_dir" ] || continue
      slug=$(basename "$project_dir")
      memory_dir="''${project_dir%/}/memory"

      if is_dotfiles_slug "$slug"; then
        dest="$shared_dir"
      else
        dest="$shared_dir/$slug"
        mkdir -p "$dest"
      fi

      if [ -L "$memory_dir" ]; then
        : # already a symlink -- idempotent re-run, nothing to do.
      elif [ -d "$memory_dir" ]; then
        if [ -z "$(dest_has_content "$dest")" ]; then
          echo "claude-memory-sync: migrating $memory_dir into $dest"
          cp -a "$memory_dir/." "$dest/"
          rm -rf "$memory_dir"
          ln -s "$dest" "$memory_dir"
        else
          echo "claude-memory-sync: both $memory_dir and $dest have content -- leaving $memory_dir as a real directory, not symlinking. Resolve manually, then remove $memory_dir so the next run can symlink it." >&2
        fi
      else
        ln -s "$dest" "$memory_dir"
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

      mkdir -p "$project_dir"
      if [ -L "$memory_dir" ] || [ -e "$memory_dir" ]; then
        : # already linked (pass 1) or real content left alone above
      else
        ln -s "$dest" "$memory_dir"
      fi
    done
  '';
}
