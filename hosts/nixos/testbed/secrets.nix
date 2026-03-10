{...}: {
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["deatrin"];
    secrets = {
      tailscaleKey = {
        path = "/run/opnix/tailscale-key";
        reference = "op://nix_secrets/tailscale-key/key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      cfApiToken = {
        path = "/run/opnix/cf-api-token";
        reference = "op://nix_secrets/deatrindev/cf_token";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      acmeEmail = {
        path = "/run/opnix/acme-email";
        reference = "op://nix_secrets/deatrindev/email";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      traefikDashboard = {
        path = "/run/opnix/traefik-dashboard-users";
        reference = "op://nix_secrets/traefik/traefik_dashoboard";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      piholeAdmin = {
        path = "/run/opnix/pihole-env";
        reference = "op://nix_secrets/pihole/piihole_admin";
        owner = "root";
        group = "root";
        mode = "0600";
      };
    };
  };
}
