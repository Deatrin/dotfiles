{
  config,
  pkgs,
  ...
}: {
  # the nix expression enabling tailscale packages and service, networking rules, and the systemd autoconnect unit file
  # tailscale-key secret is managed by opnix (see opnix-system.nix)

  # We'll install the package to the system, enable the service, and set up some networking rules
  environment.systemPackages = with pkgs.unstable; [tailscale];
  services.tailscale.enable = true;
  networking = {
    firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [config.services.tailscale.port];
      trustedInterfaces = ["tailscale0"];
    };
  };

  # Here is the magic, where we automatically connect with the tailscale CLI by passing our secret token from opnix
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # We must make sure that the tailscale service is running before trying to connect
    # AND that opnix has provisioned the secret file
    after = ["network-pre.target" "tailscale.service" "opnix-secrets.service"];
    wants = ["network-pre.target" "tailscale.service"];
    requires = ["opnix-secrets.service"];
    wantedBy = ["multi-user.target"];

    # Set this service as a oneshot job
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "60s";
    };

    # Run the following shell script for the job, passing the opnix-managed secret for the tailscale connection
    script = with pkgs; ''
      set -eu

      # wait for tailscaled to settle
      echo "Waiting for tailscaled to be ready..."
      sleep 5

      # check if we are already authenticated to tailscale
      echo "Checking Tailscale status..."
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      echo "Current status: $status"

      if [ "$status" = "Running" ]; then
          echo "Already connected to Tailscale"
          exit 0
      fi

      # verify secret file exists
      if [ ! -f "/run/opnix/tailscale-key" ]; then
          echo "ERROR: Tailscale key file not found at /run/opnix/tailscale-key"
          exit 1
      fi

      # otherwise authenticate with tailscale
      echo "Connecting to Tailscale..."
      ${tailscale}/bin/tailscale up --authkey "file:/run/opnix/tailscale-key"
      echo "Successfully connected to Tailscale"
    '';
  };
}
