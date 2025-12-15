{
  config,
  lib,
  pkgs,
  ...
}: {
  # System-level opnix for NixOS
  services.onepassword-secrets = {
    enable = true;
    # Ensure deatrin user has access to onepassword-secrets group
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
