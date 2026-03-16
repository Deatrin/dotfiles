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
#         storage/
#         var-lib/
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

      SSH_CMD="ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new -o BatchMode=yes"
      RSYNC_SSH="rsync -az --delete --numeric-ids -e '$SSH_CMD'"

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
      if ! $SSH_CMD -o ConnectTimeout=10 "$TRUENAS_USER@$TRUENAS_HOST" true 2>/dev/null; then
        pushover "Backup Error — nauvoo" "Cannot reach TrueNAS at $TRUENAS_HOST — is it online?"
        exit 1
      fi

      pushover "Backup Starting — nauvoo" "Syncing /var/lib to TrueNAS ($DATE)"

      # Build link-dest args (skip if no previous snapshot exists)
      LINK_STORAGE=""
      LINK_VARLIB=""
      if $SSH_CMD "$TRUENAS_USER@$TRUENAS_HOST" "test -e $LATEST" 2>/dev/null; then
        LINK_STORAGE="--link-dest=$LATEST/storage"
        LINK_VARLIB="--link-dest=$LATEST/var-lib"
      fi

      # Sync /storage (disabled for initial testing — re-enable once /var/lib is verified)
      # eval "$RSYNC_SSH $LINK_STORAGE /storage/ $TRUENAS_USER@$TRUENAS_HOST:$SNAPSHOT/storage/" \
      #   || fail "/storage rsync" $?

      # Sync /var/lib
      eval "$RSYNC_SSH $LINK_VARLIB /var/lib/ $TRUENAS_USER@$TRUENAS_HOST:$SNAPSHOT/var-lib/" \
        || fail "/var/lib rsync" $?

      # Update latest symlink
      $SSH_CMD "$TRUENAS_USER@$TRUENAS_HOST" \
        "ln -sfn $SNAPSHOT $LATEST" \
        || fail "updating latest symlink" $?

      pushover "Backup Finished — nauvoo" "Snapshot $DATE complete. /var/lib synced to TrueNAS."
    '';
  };
in {
  systemd.services.nauvoo-backup = {
    description = "Nauvoo → TrueNAS rsync backup";
    after = ["network-online.target" "opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe backupScript;
      User = "root";
      # Prevent accidental concurrent runs
      RemainAfterExit = false;
    };
  };
}
