# Nauvoo → TrueNAS rsync backup
#
# Manually triggered: sudo systemctl start nauvoo-backup
#
# Secrets required:
#   /run/opnix/truenas-private-key     — SSH private key for truenas_admin
#   /run/opnix/pushover-backup-token   — Pushover app token for backup notifications
#   /run/opnix/pushover-user-token     — Pushover user token (shared)
#
# Destination layout on TrueNAS:
#   /mnt/Behemoth-Pool/Backup/nauvoo/
#     latest               → symlink to most recent snapshot
#     snapshots/
#       YYYY-MM-DD/
#         podman-volumes/  ← named volume data (/var/lib/containers/storage/volumes/)
#         var-lib/         ← other /var/lib state; includes pgdumps/ subdir
#           pgdumps/       ← pg_dump / mysqldump output (written before rsync)
#         storage/         ← /storage/ large media (disabled until podman-volumes verified)
{pkgs, lib, ...}: let
  truenasUser = "truenas_admin";
  truenasHost = "10.1.20.45";
  truenasBase = "/mnt/Behemoth-Pool/Backup/nauvoo";

  backupScript = pkgs.writeShellApplication {
    name = "nauvoo-backup";
    runtimeInputs = [pkgs.rsync pkgs.openssh pkgs.curl pkgs.podman];
    text = ''
      TRUENAS_USER="${truenasUser}"
      TRUENAS_HOST="${truenasHost}"
      TRUENAS_BASE="${truenasBase}"
      SSH_KEY="/run/opnix/truenas-private-key"
      PUSHOVER_TOKEN="$(cat /run/opnix/pushover-backup-token)"
      PUSHOVER_USER="$(cat /run/opnix/pushover-user-token)"
      DATE="$(date +%Y-%m-%d)"
      SNAPSHOT="$TRUENAS_BASE/snapshots/$DATE"
      LATEST="$TRUENAS_BASE/latest"

      SSH_CMD=(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new -o BatchMode=yes)

      rsync_to() {
        local src="$1"
        local dest_suffix="$2"
        local link_dest_arg="$3"
        shift 3
        # shellcheck disable=SC2086
        rsync -az --delete --no-owner --no-group --no-perms --chmod=D755 \
          -e "''${SSH_CMD[*]}" \
          $link_dest_arg \
          "$@" \
          "$src" \
          "$TRUENAS_USER@$TRUENAS_HOST:$SNAPSHOT/$dest_suffix/"
      }

      pushover() {
        local title="$1"
        local message="$2"
        curl -s --form-string "token=$PUSHOVER_TOKEN" \
          --form-string "user=$PUSHOVER_USER" \
          --form-string "title=$title" \
          --form-string "message=$message" \
          https://api.pushover.net/1/messages.json > /dev/null
      }

      fail() {
        local part="$1"
        local exit_code="$2"
        pushover "Backup Error — nauvoo" "Failed during: $part (exit $exit_code). Check: journalctl -u nauvoo-backup"
        exit "$exit_code"
      }

      # Check TrueNAS is reachable
      if ! "''${SSH_CMD[@]}" -o ConnectTimeout=10 "$TRUENAS_USER@$TRUENAS_HOST" true 2>/dev/null; then
        pushover "Backup Error — nauvoo" "Cannot reach TrueNAS at $TRUENAS_HOST — is it online?"
        exit 1
      fi

      pushover "Backup Starting — nauvoo" "Dumping databases + syncing to TrueNAS ($DATE) — /storage will take a while"

      # ── Database dumps ────────────────────────────────────────────────────────
      # Written to /var/lib/pgdumps/ which is picked up by the var-lib rsync.
      # Non-fatal: warns if a container is offline but does not abort the backup.
      DUMP_DIR="/var/lib/pgdumps"
      mkdir -p "$DUMP_DIR"

      # pg_dump helper — $5 is optional path to a file containing the password
      dump_pg() {
        local name="$1" container="$2" user="$3" dbname="$4" passfile="''${5:-}"
        local extra_env=()
        if [[ -n "$passfile" ]]; then
          extra_env=(-e "PGPASSWORD=$(cat "$passfile")")
        fi
        if podman exec "''${extra_env[@]}" "$container" \
            pg_dump -U "$user" "$dbname" > "$DUMP_DIR/''${name}.sql"; then
          echo "dump ok: $name"
        else
          echo "WARNING: pg_dump failed for $name (container offline?)" >&2
          rm -f "$DUMP_DIR/''${name}.sql"
        fi
      }

      # Trust-auth Postgres (no password needed — POSTGRES_HOST_AUTH_METHOD=trust)
      dump_pg forgejo   forgejo-db   forgejo   forgejo
      dump_pg nextcloud nextcloud-db nextcloud nextcloud
      dump_pg paperless paperless-db paperless paperless
      dump_pg immich    immich-db    postgres  immich

      # Password-auth Postgres
      dump_pg netbox   netbox-postgres   netbox   netbox   /run/opnix/netbox-db-password
      dump_pg manyfold manyfold-postgres manyfold manyfold /run/opnix/manyfold-db-password

      # MariaDB (romm)
      if podman exec \
          -e "MYSQL_PWD=$(cat /run/opnix/romm-db-password)" \
          romm-db mariadb-dump -u romm-user romm > "$DUMP_DIR/romm.sql"; then
        echo "dump ok: romm"
      else
        echo "WARNING: mysqldump failed for romm (container offline?)" >&2
        rm -f "$DUMP_DIR/romm.sql"
      fi
      # ─────────────────────────────────────────────────────────────────────────

      # Build link-dest args (skip if no previous snapshot exists)
      LINK_VOLUMES=""
      LINK_VARLIB=""
      LINK_STORAGE=""
      if "''${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" "test -e $LATEST" 2>/dev/null; then
        LINK_VOLUMES="--link-dest=$LATEST/podman-volumes"
        LINK_VARLIB="--link-dest=$LATEST/var-lib"
        LINK_STORAGE="--link-dest=$LATEST/storage"
      fi

      # Create snapshot directories on TrueNAS
      "''${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" \
        "mkdir -p $SNAPSHOT/podman-volumes $SNAPSHOT/var-lib $SNAPSHOT/storage" \
        || fail "creating snapshot directories" $?

      # Sync named volumes (the actual persistent data — no overlay2 layer cache here)
      rsync_to /var/lib/containers/storage/volumes/ podman-volumes "$LINK_VOLUMES" \
        || fail "podman-volumes rsync" $?

      # Sync other /var/lib state (nextcloud, syncthing, netbox tmpfiles, etc.)
      # Excludes container image layers and overlay filesystems — only regular files
      rsync_to /var/lib/ var-lib "$LINK_VARLIB" \
        --exclude='containers/storage/overlay/' \
        --exclude='containers/storage/overlay-images/' \
        --exclude='containers/storage/overlay-layers/' \
        --exclude='docker/' \
        || fail "/var/lib rsync" $?

      # Sync /storage (pictures, movies, TV, music, 3D models — 8.3T local disk)
      rsync_to /storage/ storage "$LINK_STORAGE" \
        || fail "/storage rsync" $?

      # Update latest symlink (after all rsyncs succeed)
      "''${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" \
        "ln -sfn $SNAPSHOT $LATEST" \
        || fail "updating latest symlink" $?

      pushover "Backup Finished — nauvoo" "Snapshot $DATE complete. DB dumps + podman volumes + /var/lib + /storage synced to TrueNAS."
    '';
  };
in {
  systemd.services.nauvoo-backup = {
    description = "Nauvoo → TrueNAS rsync backup";
    after = ["network-online.target" "opnix-secrets.service"];
    requires = ["network-online.target" "opnix-secrets.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe backupScript;
      User = "root";
      # Prevent accidental concurrent runs
      RemainAfterExit = false;
    };
  };
}
