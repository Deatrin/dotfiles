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
      ExecStart = "${pkgs.podman}/bin/podman auto-update";
      ExecStartPre = "-${lib.getExe (pkgs.writeShellApplication {
        name = "podman-auto-update-notify-start";
        runtimeInputs = [pkgs.curl];
        text = ''
          curl -sf \
            --form-string "token=$(cat /run/opnix/pushover-podman-token)" \
            --form-string "user=$(cat /run/opnix/pushover-user-token)" \
            --form-string "title=nauvoo: container update starting" \
            --form-string "message=podman auto-update has started" \
            https://api.pushover.net/1/messages.json || true
        '';
      })}";
    };
    after = ["network-online.target" "opnix-secrets.service"];
    wants = ["network-online.target" "opnix-secrets.service"];
  };

  # Send Pushover notification after auto-update completes with the update summary
  systemd.services.podman-auto-update-notify = {
    description = "Notify Pushover after podman auto-update";
    after = ["podman-auto-update.service" "opnix-secrets.service"];
    wants = ["opnix-secrets.service"];
    wantedBy = ["podman-auto-update.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "podman-auto-update-notify-done";
        runtimeInputs = [pkgs.curl pkgs.systemd];
        text = ''
          OUTPUT=$(journalctl -u podman-auto-update.service -n 50 --no-pager -o cat 2>/dev/null || echo "could not retrieve output")
          curl -sf \
            --form-string "token=$(cat /run/opnix/pushover-podman-token)" \
            --form-string "user=$(cat /run/opnix/pushover-user-token)" \
            --form-string "title=nauvoo: container update done" \
            --form-string "message=''${OUTPUT:-completed with no output}" \
            https://api.pushover.net/1/messages.json
        '';
      });
    };
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
