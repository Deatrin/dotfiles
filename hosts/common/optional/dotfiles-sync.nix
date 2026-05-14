{ config, lib, pkgs, ... }:
let
  cfg = config.services.dotfiles-sync;

  # Runs nixos-rebuild switch in a detached transient systemd unit so it survives
  # switch-to-configuration restarting dotfiles-sync.service when the unit file changes.
  applyScript = pkgs.writeShellScript "dotfiles-apply" ''
    set -euo pipefail

    PUSHOVER_APP=$(cat "$PUSHOVER_APP_FILE")
    PUSHOVER_USER=$(cat "$PUSHOVER_USER_FILE")
    APPROVE_TOKEN=$(cat "$APPROVE_TOKEN_FILE")

    pushover() {
      local title=$1 msg=$2 url=''${3:-} url_title=''${4:-}
      local args=(
        --form-string "token=$PUSHOVER_APP"
        --form-string "user=$PUSHOVER_USER"
        --form-string "title=$title"
        --form-string "message=$msg"
      )
      [[ -n "$url" ]] && args+=(--form-string "url=$url" --form-string "url_title=$url_title")
      curl -sf "''${args[@]}" https://api.pushover.net/1/messages.json || true
    }

    SWITCH_LOG=$(nixos-rebuild switch --flake "$FLAKE_REF#$FLAKE_ATTR" 2>&1) || {
      pushover "nauvoo: switch failed ✗" "Switch failed for $COMMIT_SHORT.\n$(echo "$SWITCH_LOG" | tail -10)"
      exit 1
    }

    if [[ "$(readlink /run/booted-system/{initrd,kernel,kernel-modules})" \
       == "$(readlink /run/current-system/{initrd,kernel,kernel-modules})" ]]; then
      pushover "nauvoo: rebuilt ✓" "Commit $COMMIT_SHORT applied, no reboot needed."
    else
      touch "$STATE_DIR/pending-reboot"
      TAILSCALE_IP=$(ip -4 addr show tailscale0 2>/dev/null \
        | awk '/inet / {print $2}' | cut -d/ -f1 \
        || echo "nauvoo")
      APPROVE_URL="http://$TAILSCALE_IP:$PORT/approve?token=$APPROVE_TOKEN"
      pushover "nauvoo: reboot required" \
        "Commit $COMMIT_SHORT applied. Kernel updated — tap to approve reboot." \
        "$APPROVE_URL" "Approve Reboot"
    fi
  '';

  syncScript = pkgs.writeShellScript "dotfiles-sync" ''
    set -euo pipefail

    OWNER="Deatrin"
    REPO="dotfiles"
    BRANCH="${cfg.branch}"
    FLAKE_ATTR="${cfg.flakeAttr}"
    STATE_DIR="/var/lib/dotfiles-sync"
    PORT="${toString cfg.approvePort}"
    LAST_APPLIED="$STATE_DIR/last-applied-rev"

    PUSHOVER_APP=$(cat "${cfg.pushoverAppTokenFile}")
    PUSHOVER_USER=$(cat "${cfg.pushoverUserTokenFile}")
    APPROVE_TOKEN=$(cat "${cfg.approveTokenFile}")

    pushover() {
      local title=$1 msg=$2 url=''${3:-} url_title=''${4:-}
      local args=(
        --form-string "token=$PUSHOVER_APP"
        --form-string "user=$PUSHOVER_USER"
        --form-string "title=$title"
        --form-string "message=$msg"
      )
      [[ -n "$url" ]] && args+=(--form-string "url=$url" --form-string "url_title=$url_title")
      curl -sf "''${args[@]}" https://api.pushover.net/1/messages.json || true
    }

    mkdir -p "$STATE_DIR"

    # Check for new commits via GitHub API (public repo, no auth needed)
    API_RESPONSE=$(curl -sf "https://api.github.com/repos/$OWNER/$REPO/commits/$BRANCH")
    REMOTE_REV=$(echo "$API_RESPONSE" | jq -r .sha)
    [[ "$REMOTE_REV" == "null" || -z "$REMOTE_REV" ]] && exit 0

    LOCAL_REV=""
    [[ -f "$LAST_APPLIED" ]] && LOCAL_REV=$(cat "$LAST_APPLIED")
    [[ "$REMOTE_REV" == "$LOCAL_REV" ]] && exit 0

    # Already waiting for reboot approval from a previous rebuild
    [[ -f "$STATE_DIR/pending-reboot" ]] && exit 0

    COMMIT_MSG=$(echo "$API_RESPONSE" | jq -r '.commit.message' | head -3)
    COMMIT_SHORT=''${REMOTE_REV:0:8}
    FLAKE_REF="github:$OWNER/$REPO/$REMOTE_REV"

    # Build test — dry-activate is safe, switch-to-configuration dry-activate
    # does not restart services
    BUILD_LOG=$(nixos-rebuild dry-activate --flake "$FLAKE_REF#$FLAKE_ATTR" 2>&1) || {
      pushover "nauvoo: build failed ✗" "Commit $COMMIT_SHORT failed:\n$(echo "$BUILD_LOG" | tail -15)"
      exit 1
    }

    # Save rev before launching apply so re-runs are idempotent if we get restarted
    echo "$REMOTE_REV" > "$LAST_APPLIED"

    # Launch the switch in a detached transient unit. switch-to-configuration will
    # restart dotfiles-sync.service when it sees the unit file changed, which kills
    # us — but the transient apply unit is outside our cgroup and runs to completion.
    systemd-run \
      --no-block \
      --unit="dotfiles-apply-$COMMIT_SHORT" \
      --description="Dotfiles switch $COMMIT_SHORT" \
      --property=Type=oneshot \
      --property="Environment=HOME=/root" \
      --property="Environment=NIX_REMOTE=daemon" \
      --property="Environment=PATH=${lib.makeBinPath (with pkgs; [curl jq iproute2])}:/run/current-system/sw/bin" \
      --property="Environment=FLAKE_REF=$FLAKE_REF" \
      --property="Environment=FLAKE_ATTR=${cfg.flakeAttr}" \
      --property="Environment=COMMIT_SHORT=$COMMIT_SHORT" \
      --property="Environment=STATE_DIR=$STATE_DIR" \
      --property="Environment=PORT=$PORT" \
      --property="Environment=PUSHOVER_APP_FILE=${cfg.pushoverAppTokenFile}" \
      --property="Environment=PUSHOVER_USER_FILE=${cfg.pushoverUserTokenFile}" \
      --property="Environment=APPROVE_TOKEN_FILE=${cfg.approveTokenFile}" \
      ${applyScript}

    pushover "nauvoo: applying" "Build test passed for $COMMIT_SHORT. Applying...\n$COMMIT_MSG"
  '';

  approveServerPy = pkgs.writeText "dotfiles-approve-server.py" ''
    import http.server
    import urllib.parse
    import subprocess
    import os
    import pathlib

    PORT = ${toString cfg.approvePort}
    STATE_FILE = "/var/lib/dotfiles-sync/pending-reboot"
    APPROVE_TOKEN_FILE = "${cfg.approveTokenFile}"
    PUSHOVER_APP_FILE = "${cfg.pushoverAppTokenFile}"
    PUSHOVER_USER_FILE = "${cfg.pushoverUserTokenFile}"
    CURL = "${pkgs.curl}/bin/curl"
    SYSTEMD_RUN = "${pkgs.systemd}/bin/systemd-run"
    SYSTEMCTL = "${pkgs.systemd}/bin/systemctl"


    def pushover(title, msg):
        try:
            app = pathlib.Path(PUSHOVER_APP_FILE).read_text().strip()
            user = pathlib.Path(PUSHOVER_USER_FILE).read_text().strip()
            subprocess.run([CURL, "-sf",
                "--form-string", f"token={app}",
                "--form-string", f"user={user}",
                "--form-string", f"title={title}",
                "--form-string", f"message={msg}",
                "https://api.pushover.net/1/messages.json"], check=False)
        except Exception:
            pass


    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            parsed = urllib.parse.urlparse(self.path)
            params = urllib.parse.parse_qs(parsed.query)

            if parsed.path != "/approve":
                self.send_response(404)
                self.end_headers()
                return

            token = params.get("token", [""])[0]

            try:
                expected = pathlib.Path(APPROVE_TOKEN_FILE).read_text().strip()
            except Exception:
                self.send_response(500)
                self.end_headers()
                return

            if not os.path.exists(STATE_FILE) or token != expected:
                self.send_response(403)
                self.send_header("Content-Type", "text/html")
                self.end_headers()
                self.wfile.write(b"<html><body><h2>No pending reboot or invalid token.</h2></body></html>")
                return

            os.unlink(STATE_FILE)
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(b"<html><body><h2>Reboot approved. nauvoo is rebooting in 5 seconds...</h2></body></html>")
            self.wfile.flush()
            pushover("nauvoo: rebooting", "Reboot approved — restarting now.")
            subprocess.Popen([SYSTEMD_RUN, "--on-active=5s", SYSTEMCTL, "reboot"])

        def log_message(self, *args):
            pass


    http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
  '';

in {
  options.services.dotfiles-sync = {
    enable = lib.mkEnableOption "dotfiles auto-sync from GitHub with Pushover notifications and approval-gated reboot";

    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
    };

    flakeAttr = lib.mkOption {
      type = lib.types.str;
      description = "NixOS flake attribute to build (e.g. \"nauvoo\")";
    };

    approvePort = lib.mkOption {
      type = lib.types.port;
      default = 45923;
    };

    pushoverAppTokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/opnix/dotfiles-sync-pushover-token";
    };

    pushoverUserTokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/opnix/pushover-user-token";
    };

    approveTokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/opnix/dotfiles-approve-token";
    };
  };

  config = lib.mkIf cfg.enable {
    # We manage rebuilds; disable the built-in hourly auto-upgrade
    system.autoUpgrade.enable = lib.mkForce false;

    systemd.timers.dotfiles-sync = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
        Unit = "dotfiles-sync.service";
      };
    };

    systemd.services.dotfiles-sync = {
      description = "Dotfiles auto-sync from GitHub";
      after = ["network-online.target" "op-connect-secrets.service"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = syncScript;
        Environment = [
          "PATH=${lib.makeBinPath (with pkgs; [curl jq iproute2])}:/run/current-system/sw/bin"
          "HOME=/root"
          "NIX_REMOTE=daemon"
        ];
        StateDirectory = "dotfiles-sync";
      };
    };

    systemd.services.dotfiles-approve = {
      description = "Dotfiles reboot approval listener";
      wantedBy = ["multi-user.target"];
      after = ["op-connect-secrets.service"];
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${pkgs.python3}/bin/python3 ${approveServerPy}";
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "dotfiles-sync";
      };
    };

    # Only allow connections on the Tailscale interface
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [cfg.approvePort];
  };
}
