{...}: {
  # Secrets come from nauvoo's 1Password Connect server over the LAN, same as
  # tycho/artemis (modules/nixos/op-connect-secrets.nix). Files land in
  # /run/opnix/. Secret names must be camelCase.
  #
  # Bootstrap: on first install, place the Connect token by hand:
  #   sudo install -m600 /dev/stdin /etc/op-connect-token
  #   (paste the token, then Ctrl+D)
  # Until it exists, secrets aren't fetched (the warning below says so on
  # every switch). Tailscale state in /var/lib/tailscale covers later reboots
  # when nauvoo is unreachable.
  system.activationScripts.checkOpConnectToken = ''
    if [ ! -f /etc/op-connect-token ]; then
      echo ""
      echo "WARNING: /etc/op-connect-token is missing."
      echo "Secrets will not be fetched until you run:"
      echo "  sudo install -m600 /dev/stdin /etc/op-connect-token"
      echo "(paste the op-connect token, then Ctrl+D)"
      echo ""
    fi
  '';

  services.op-connect-secrets = {
    enable = true;
    connectHost = "http://10.1.30.100:8080";
    tokenFile = "/etc/op-connect-token";
    localApi = false;
    users = ["deatrin"];
    secrets = {
      # Required: hosts/common/nixos/tailscale.nix authenticates with this.
      tailscaleKey = {
        path = "/run/opnix/tailscale-key";
        reference = "op://nix_secrets/tailscale-key/key";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # Optional: pull from the Attic cache on nauvoo. Mint a per-host token
      # (field `<host>_token` in the `attic` item), uncomment, and set
      # dotfiles.attic-client.enable = true in default.nix.
      # atticToken = {
      #   path = "/run/opnix/attic-token";
      #   reference = "op://nix_secrets/attic/<host>_token";
      #   owner = "root";
      #   group = "root";
      #   mode = "0600";
      #   restartServices = ["attic-netrc-setup.service"];
      # };
    };
  };
}
