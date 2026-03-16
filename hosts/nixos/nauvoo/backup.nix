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
#         var-lib/         ← other /var/lib state (nextcloud, syncthing, etc.)
#         storage/         ← /storage/ large media (disabled until podman-volumes verified)
{pkgs, lib, ...}: let
  truenasUser = "truenas_admin";
  truenasHost = "10.1.20.45";
  truenasBase = "/mnt/Behemoth-Pool/Backup/nauvoo";

  backupScript = pkgs.writeShellApplication {
    name = "nauvoo-backup";
    runtimeInputs = [pkgs.rsync pkgs.openssh pkgs.curl];
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
        rsync -az --delete --numeric-ids \
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

      pushover "Backup Starting — nauvoo" "Syncing podman volumes + /var/lib state to TrueNAS ($DATE)"

      # Build link-dest args (skip if no previous snapshot exists)
      LINK_VOLUMES=""
      LINK_VARLIB=""
      if "''${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" "test -e $LATEST" 2>/dev/null; then
        LINK_VOLUMES="--link-dest=$LATEST/podman-volumes"
        LINK_VARLIB="--link-dest=$LATEST/var-lib"
      fi

      # Create snapshot directories on TrueNAS
      "''${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" \
        "mkdir -p $SNAPSHOT/podman-volumes $SNAPSHOT/var-lib" \
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

      # Update latest symlink
      "''${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" \
        "ln -sfn $SNAPSHOT $LATEST" \
        || fail "updating latest symlink" $?

      # Sync /storage (disabled — re-enable once podman-volumes verified)
      # rsync_to /storage/ storage "$LINK_STORAGE" \
      #   || fail "/storage rsync" $?

      pushover "Backup Finished — nauvoo" "Snapshot $DATE complete. Podman volumes + /var/lib synced to TrueNAS."
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
