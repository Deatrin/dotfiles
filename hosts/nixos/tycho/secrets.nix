{
  config,
  lib,
  pkgs,
  ...
}: {
  # Fetch secrets from nauvoo's 1Password Connect server over LAN.
  # Note: nauvoo must be reachable at 10.1.30.100:8080 — works on home LAN.
  # Tailscale re-auth is rare; persisted state in /var/lib/tailscale covers
  # the chicken-and-egg case when nauvoo isn't reachable.
  #
  # Bootstrap: place /etc/op-connect-token on tycho (same token as nauvoo)
  services.op-connect-secrets = {
    enable = true;
    connectHost = "http://10.1.30.100:8080";
    tokenFile = "/etc/op-connect-token";
    localApi = false;
    users = ["deatrin"];
    secrets = {
      tailscaleKey = {
        path = "/run/opnix/tailscale-key";
        reference = "op://nix_secrets/tailscale-key/key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
    };
  };
}
