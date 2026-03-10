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
      homepageUnifiUser = {
        path = "/run/opnix/homepage-unifi-user";
        reference = "op://nix_secrets/homepage/HOMEPAGE_UNIFI_USER";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      homepageUnifiPass = {
        path = "/run/opnix/homepage-unifi-pass";
        reference = "op://nix_secrets/homepage/HOMEPAGE_UNIFI_PASS";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      homepageLatitude = {
        path = "/run/opnix/homepage-latitude";
        reference = "op://nix_secrets/homepage/HOMEPAGE_LATITUDE";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      homepageLongitude = {
        path = "/run/opnix/homepage-longitude";
        reference = "op://nix_secrets/homepage/HOMEPAGE_LONGITUDE";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      pocketIdEncryptionKey = {
        path = "/run/opnix/pocket-id-encryption-key";
        reference = "op://nix_secrets/pocket-id/encryption_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      pocketIdMaxmindKey = {
        path = "/run/opnix/pocket-id-maxmind-key";
        reference = "op://nix_secrets/pocket-id/maxmind_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # TODO: Fill in correct op:// references before enabling DDNS
      # ddnsApiKey = {
      #   path = "/run/opnix/ddns-api-key";
      #   reference = "op://nix_secrets/<item>/api_key";
      #   owner = "root";
      #   group = "root";
      #   mode = "0600";
      # };
      # ddnsZone = {
      #   path = "/run/opnix/ddns-zone";
      #   reference = "op://nix_secrets/<item>/zone";
      #   owner = "root";
      #   group = "root";
      #   mode = "0600";
      # };
    };
  };
}
