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
    after = ["network-pre.target" "tailscale.service" "onepassword-secrets.service"];
    wants = ["network-pre.target" "tailscale.service"];
    requires = ["onepassword-secrets.service"];
    wantedBy = ["multi-user.target"];

    # Set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # Run the following shell script for the job, passing the opnix-managed secret for the tailscale connection
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then
          exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey "$(cat "/run/opnix/tailscale-key")"
    '';
  };
}
