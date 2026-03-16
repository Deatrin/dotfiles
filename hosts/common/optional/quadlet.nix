{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ];

  # Use journald log driver so all container logs flow through systemd journal
  # and are picked up by Promtail → Loki
  virtualisation.containers.containersConf.settings.containers.log_driver = "journald";

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [
        "--filter=until=24h"
        "--filter=label!=important"
      ];
    };
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable podman auto-update timer to pull new images for containers
  # with autoUpdate = "registry" and restart them automatically
  systemd.timers.podman-auto-update = {
    description = "Podman auto-update timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "900";
    };
  };

  systemd.services.podman-auto-update = {
    description = "Podman auto-update service";
    serviceConfig = {
      Type = "oneshot";
      Environment = "HOME=/root";
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "podman-auto-update-wrapper";
        runtimeInputs = [pkgs.podman pkgs.curl pkgs.gawk];
        text = ''
          # Send start notification
          curl -sf \
            --form-string "token=$(cat /run/opnix/pushover-podman-token)" \
            --form-string "user=$(cat /run/opnix/pushover-user-token)" \
            --form-string "title=nauvoo: container update starting" \
            --form-string "message=podman auto-update has started" \
            https://api.pushover.net/1/messages.json || true

          # Run update and capture output
          UPDATE_OUTPUT=$(podman auto-update 2>&1)

          # Parse: count total containers and which were updated
          UPDATED=$(echo "$UPDATE_OUTPUT" | awk 'NR>1 && $NF=="true"  {count++} END {print count+0}')
          TOTAL=$(echo   "$UPDATE_OUTPUT" | awk 'NR>1                  {count++} END {print count+0}')

          if [ "$UPDATED" -gt 0 ]; then
            UPDATED_LIST=$(echo "$UPDATE_OUTPUT" \
              | awk 'NR>1 && $NF=="true" {gsub(/\.service$/, "", $1); print "• "$1}')
            MSG="$UPDATED/$TOTAL containers updated:
          $UPDATED_LIST"
          else
            MSG="All $TOTAL containers up to date"
          fi

          # Send completion notification
          curl -sf \
            --form-string "token=$(cat /run/opnix/pushover-podman-token)" \
            --form-string "user=$(cat /run/opnix/pushover-user-token)" \
            --form-string "title=nauvoo: container update done" \
            --form-string "message=$MSG" \
            https://api.pushover.net/1/messages.json
        '';
      });
    };
    after = ["network-online.target" "opnix-secrets.service"];
    wants = ["network-online.target" "opnix-secrets.service"];
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
