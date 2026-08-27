{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    # Ensure deatrin user has access to onepassword-secrets group
    users = ["deatrin"];

    secrets = {
      autin = {
        reference = "op://nix_secrets/atuin/username";
        mode = "0600";
      };
      atticNetrc = {
        reference = "op://nix_secrets/attic/scirocco_netrc";
        mode = "0600";
      };
    };
  };
}
