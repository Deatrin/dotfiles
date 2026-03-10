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

      immichEnv = {
        path = "/run/opnix/immich-env";
        reference = "op://nix_secrets/immich/env";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      paperlessSecret = {
        path = "/run/opnix/paperless-secret";
        reference = "op://nix_secrets/paperless/env";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      rommDbPassword = {
        path = "/run/opnix/romm-db-password";
        reference = "op://nix_secrets/romm/db_password";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommDbRootPassword = {
        path = "/run/opnix/romm-db-root-password";
        reference = "op://nix_secrets/romm/db_root_password";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommAuthSecretKey = {
        path = "/run/opnix/romm-auth-secret-key";
        reference = "op://nix_secrets/romm/auth_secret_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommScreenscraperUser = {
        path = "/run/opnix/romm-screenscraper-user";
        reference = "op://nix_secrets/romm/screenscraper_user";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommScreenscraperPass = {
        path = "/run/opnix/romm-screenscraper-pass";
        reference = "op://nix_secrets/romm/screenscraper_password";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommRetroachievementsKey = {
        path = "/run/opnix/romm-retroachievements-key";
        reference = "op://nix_secrets/romm/retroachievements_api_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommSteamgriddbKey = {
        path = "/run/opnix/romm-steamgriddb-key";
        reference = "op://nix_secrets/romm/steamgriddb_api_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommIgdbClientId = {
        path = "/run/opnix/romm-igdb-client-id";
        reference = "op://nix_secrets/romm/igdb_client_id";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      rommIgdbClientSecret = {
        path = "/run/opnix/romm-igdb-client-secret";
        reference = "op://nix_secrets/romm/igdb_client_secret";
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
