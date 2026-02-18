{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ];

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
    };
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
