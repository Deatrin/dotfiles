{
  config,
  pkgs,
  lib,
  ...
}: {
  # Expose Podman as a Docker-compatible socket so the runner can spawn
  # per-job containers without needing Docker-in-Docker inside a container.
  virtualisation.podman.dockerSocket.enable = true;

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.nauvoo = {
      enable = true;
      name = "nauvoo";
      url = "https://forgejo.jennex.dev";
      # File must contain "TOKEN=<value>" format (used as EnvironmentFile by the module).
      tokenFile = "/run/opnix/forgejo-runner-token";
      # Labels map `runs-on:` values in workflows to container images.
      labels = [
        "ubuntu-latest:docker://catthehacker/ubuntu:act-latest"
        "ubuntu-22.04:docker://catthehacker/ubuntu:act-22.04"
        "nix:docker://nixos/nix:latest"
      ];
      settings = {
        container.docker_host = "unix:///run/podman/podman.sock";
        container.network = "bridge";
        container.force_pull = false;
        container.privileged = false;
        runner.fetch_timeout = "30s";
      };
    };
  };

  # Ensure the runner waits for opnix to provision the token file before starting.
  # The module uses DynamicUser=true and SupplementaryGroups=podman itself.
  #
  # Also wait for forgejo-server.service (Quadlet container) so the runner doesn't
  # race against Traefik/DNS on boot. StartLimitIntervalSec=0 prevents the service
  # from entering a terminal failed state if Forgejo isn't fully reachable yet.
  systemd.services."gitea-runner-nauvoo" = {
    after = ["opnix-secrets.service" "forgejo-server.service"];
    requires = ["opnix-secrets.service"];
    wants = ["forgejo-server.service"];
    startLimitIntervalSec = 0;
    serviceConfig.ExecStartPre = [
      # On nixos-rebuild switch, all podman quadlet containers (including forgejo
      # itself) get restarted, leaving forgejo.jennex.dev briefly unreachable. The
      # runner's startup "Declare" call fails hard in that window, marking the unit
      # failed (which switch-to-configuration then reports as a switch failure).
      # Wait (best-effort) for forgejo to come back before launching the runner.
      "-${pkgs.writeShellScript "wait-for-forgejo" ''
        for i in $(seq 1 60); do
          ${pkgs.curl}/bin/curl -s -o /dev/null --max-time 5 https://forgejo.jennex.dev/ && exit 0
          sleep 2
        done
        exit 0
      ''}"
    ];
  };
}
