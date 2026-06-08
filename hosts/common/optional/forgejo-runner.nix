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

  # Runner user needs access to the Podman Docker-compat socket.
  # The NixOS module creates user/group "gitea-runner-<instance-name>".
  users.users."gitea-runner-nauvoo".extraGroups = ["docker"];

  # Ensure the runner waits for opnix to provision the token file before starting.
  systemd.services."gitea-runner-nauvoo" = {
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
  };
}
