{...}: {
  # opnix disabled — nauvoo uses op-connect-secrets (local Connect server) instead
  services.onepassword-secrets.enable = false;

  services.op-connect-secrets = {
    enable = true;
    connectHost = "http://127.0.0.1:8080";
    tokenFile = "/etc/op-connect-token";
    users = ["deatrin"];
    secrets = {
      tailscaleKey = {
        path = "/run/opnix/tailscale-key";
        reference = "op://nix_secrets/tailscale-key/key";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["tailscale-autoconnect.service"];
      };
      cfApiToken = {
        path = "/run/opnix/cf-api-token";
        reference = "op://nix_secrets/Cloudflare API Key/jennexDEV";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["traefik-env-setup.service" "traefik.service"];
      };
      acmeEmail = {
        path = "/run/opnix/acme-email";
        reference = "op://nix_secrets/deatrindev/email";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["traefik-env-setup.service" "traefik.service"];
      };
      traefikDashboard = {
        path = "/run/opnix/traefik-dashboard-users";
        reference = "op://nix_secrets/traefik/traefik_dashoboard";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["traefik-env-setup.service" "traefik.service"];
      };
      piholeAdmin = {
        path = "/run/opnix/pihole-env";
        reference = "op://nix_secrets/pihole/piihole_admin";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["pihole.service"];
      };
      homepageTraefikUsername = {
        path = "/run/opnix/homepage-traefik-username";
        reference = "op://nix_secrets/homepage/traefik username";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      homepageTraefik = {
        path = "/run/opnix/homepage-traefik";
        reference = "op://nix_secrets/homepage/traefik";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      homepagePihole = {
        path = "/run/opnix/homepage-pihole";
        reference = "op://nix_secrets/homepage/pihole";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      homepageUnifiUser = {
        path = "/run/opnix/homepage-unifi-user";
        reference = "op://nix_secrets/homepage/HOMEPAGE_UNIFI_USER";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      homepageUnifiPass = {
        path = "/run/opnix/homepage-unifi-pass";
        reference = "op://nix_secrets/homepage/HOMEPAGE_UNIFI_PASS";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      homepageLatitude = {
        path = "/run/opnix/homepage-latitude";
        reference = "op://nix_secrets/homepage/HOMEPAGE_LATITUDE";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      homepageLongitude = {
        path = "/run/opnix/homepage-longitude";
        reference = "op://nix_secrets/homepage/HOMEPAGE_LONGITUDE";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      immichEnv = {
        path = "/run/opnix/immich-env";
        reference = "op://nix_secrets/immich/env";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["immich-server.service" "immich-ml.service"];
      };
      paperlessSecret = {
        path = "/run/opnix/paperless-secret";
        reference = "op://nix_secrets/paperless/env";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["paperless.service"];
      };
      rommDbPassword = {
        path = "/run/opnix/romm-db-password";
        reference = "op://nix_secrets/romm/db_password";
        owner = "root";
        group = "root";
        mode = "0600";
        # used by both db and app env-setup
        restartServices = ["romm-db-env-setup.service" "romm-db.service" "romm-env-setup.service" "romm.service"];
      };
      rommDbRootPassword = {
        path = "/run/opnix/romm-db-root-password";
        reference = "op://nix_secrets/romm/db_root_password";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-db-env-setup.service" "romm-db.service"];
      };
      rommAuthSecretKey = {
        path = "/run/opnix/romm-auth-secret-key";
        reference = "op://nix_secrets/romm/auth_secret_key";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      rommScreenscraperUser = {
        path = "/run/opnix/romm-screenscraper-user";
        reference = "op://nix_secrets/romm/screenscraper_user";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      rommScreenscraperPass = {
        path = "/run/opnix/romm-screenscraper-pass";
        reference = "op://nix_secrets/romm/screenscraper_password";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      rommRetroachievementsKey = {
        path = "/run/opnix/romm-retroachievements-key";
        reference = "op://nix_secrets/romm/retroachievements_api_key";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      rommSteamgriddbKey = {
        path = "/run/opnix/romm-steamgriddb-key";
        reference = "op://nix_secrets/romm/steamgriddb_api_key";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      rommIgdbClientId = {
        path = "/run/opnix/romm-igdb-client-id";
        reference = "op://nix_secrets/romm/igdb_client_id";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      rommIgdbClientSecret = {
        path = "/run/opnix/romm-igdb-client-secret";
        reference = "op://nix_secrets/romm/igdb_client_secret";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["romm-env-setup.service" "romm.service"];
      };
      pocketIdEncryptionKey = {
        path = "/run/opnix/pocket-id-encryption-key";
        reference = "op://nix_secrets/pocket-id/encryption_key";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["pocket-id-env-setup.service" "pocket-id.service"];
      };
      pocketIdMaxmindKey = {
        path = "/run/opnix/pocket-id-maxmind-key";
        reference = "op://nix_secrets/pocket-id/maxmind_key";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["pocket-id-env-setup.service" "pocket-id.service"];
      };
      forgejoRunnerToken = {
        path = "/run/opnix/forgejo-runner-token";
        reference = "op://nix_secrets/forgejo/runner_token";
        owner = "root";
        group = "root";
        mode = "0600";
        # no runner service yet — DinD doesn't work in Podman on NixOS
        restartServices = [];
      };
      nextcloudAdminPassword = {
        path = "/run/opnix/nextcloud-admin-password";
        reference = "op://nix_secrets/Nextcloud/admin password";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["nextcloud-env-setup.service" "nextcloud.service"];
      };
      proxmoxTokenId = {
        path = "/run/opnix/proxmox-token-id";
        reference = "op://nix_secrets/homepage/tokenid";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      proxmoxTokenSecret = {
        path = "/run/opnix/proxmox-token-secret";
        reference = "op://nix_secrets/homepage/token secret";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      plexToken = {
        path = "/run/opnix/plex-token";
        reference = "op://nix_secrets/plex/token";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      traefikForwardAuthClientId = {
        path = "/run/opnix/traefik-forward-auth-client-id";
        reference = "op://nix_secrets/traefik/client_id";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["traefik-forward-auth-env-setup.service" "traefik-forward-auth.service"];
      };
      traefikForwardAuthClientSecret = {
        path = "/run/opnix/traefik-forward-auth-client-secret";
        reference = "op://nix_secrets/traefik/client_secret";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["traefik-forward-auth-env-setup.service" "traefik-forward-auth.service"];
      };
      traefikForwardAuthCookieSecret = {
        path = "/run/opnix/traefik-forward-auth-cookie-secret";
        reference = "op://nix_secrets/traefik/cookie_secret";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["traefik-forward-auth-env-setup.service" "traefik-forward-auth.service"];
      };
      monitoringUnpollerUsername = {
        path = "/run/opnix/monitoring-unpoller-username";
        reference = "op://nix_secrets/monitoring/unpoller-username";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["monitoring-env-setup.service" "monitoring-unpoller.service"];
      };
      monitoringUnpollerPassword = {
        path = "/run/opnix/monitoring-unpoller-password";
        reference = "op://nix_secrets/monitoring/unpoller-password";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["monitoring-env-setup.service" "monitoring-unpoller.service"];
      };
      monitoringGrafanaAdminPassword = {
        path = "/run/opnix/monitoring-grafana-admin-password";
        reference = "op://nix_secrets/monitoring/grafana-admin_password";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["monitoring-env-setup.service" "monitoring-grafana.service"];
      };
      manyfoldDbPassword = {
        path = "/run/opnix/manyfold-db-password";
        reference = "op://nix_secrets/ManyFold/db_password";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["manyfold-env-setup.service" "manyfold-postgres.service" "manyfold.service"];
      };
      manyfoldSecretKeyBase = {
        path = "/run/opnix/manyfold-secret-key-base";
        reference = "op://nix_secrets/ManyFold/secret_key_base";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["manyfold-env-setup.service" "manyfold.service"];
      };
      netboxSecretKey = {
        path = "/run/opnix/netbox-secret-key";
        reference = "op://nix_secrets/netbox/netboxSecretKey";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["netbox-app-env-setup.service" "netbox.service" "netbox-worker.service"];
      };
      netboxDbPassword = {
        path = "/run/opnix/netbox-db-password";
        reference = "op://nix_secrets/netbox/netboxDbPassword";
        owner = "root";
        group = "root";
        mode = "0600";
        # used by both db env-setup and app env-setup
        restartServices = ["netbox-db-env-setup.service" "netbox-postgres.service" "netbox-app-env-setup.service" "netbox.service" "netbox-worker.service"];
      };
      netboxRedisPassword = {
        path = "/run/opnix/netbox-redis-password";
        reference = "op://nix_secrets/netbox/netboxRedisPassword";
        owner = "root";
        group = "root";
        mode = "0600";
        # used by redis env-setup and app env-setup
        restartServices = ["netbox-redis-env-setup.service" "netbox-redis.service" "netbox-app-env-setup.service" "netbox.service" "netbox-worker.service"];
      };
      netboxRedisCachePassword = {
        path = "/run/opnix/netbox-redis-cache-password";
        reference = "op://nix_secrets/netbox/netboxRedisCachePassword";
        owner = "root";
        group = "root";
        mode = "0600";
        # used by redis-cache env-setup and app env-setup
        restartServices = ["netbox-redis-cache-env-setup.service" "netbox-redis-cache.service" "netbox-app-env-setup.service" "netbox.service" "netbox-worker.service"];
      };
      netboxSuperuserName = {
        path = "/run/opnix/netbox-superuser-name";
        reference = "op://nix_secrets/netbox/netboxSuperuserName";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["netbox-app-env-setup.service" "netbox.service"];
      };
      netboxSuperuserPassword = {
        path = "/run/opnix/netbox-superuser-password";
        reference = "op://nix_secrets/netbox/netboxSuperuserPassword";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["netbox-app-env-setup.service" "netbox.service"];
      };
      netboxSuperuserEmail = {
        path = "/run/opnix/netbox-superuser-email";
        reference = "op://nix_secrets/netbox/netboxSuperuserEmail";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["netbox-app-env-setup.service" "netbox.service"];
      };
      netboxSuperuserApiToken = {
        path = "/run/opnix/netbox-superuser-api-token";
        reference = "op://nix_secrets/netbox/netboxSuperuserApiToken";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["netbox-app-env-setup.service" "netbox.service"];
      };
      netboxApiTokenPeppers = {
        path = "/run/opnix/netbox-api-token-peppers";
        reference = "op://nix_secrets/netbox/api_token_peppers";
        owner = "root";
        group = "root";
        mode = "0600";
        # mounted directly into netbox container (not via env-setup)
        restartServices = ["netbox.service" "netbox-worker.service"];
      };
      pushoverPodmanToken = {
        path = "/run/opnix/pushover-podman-token";
        reference = "op://nix_secrets/Pushover/podmanToken";
        owner = "root";
        group = "root";
        mode = "0600";
        # read at runtime by auto-update wrapper script — no restart needed
        restartServices = [];
      };
      pushoverUserToken = {
        path = "/run/opnix/pushover-user-token";
        reference = "op://nix_secrets/Pushover/pushoverUserToken";
        owner = "root";
        group = "root";
        mode = "0600";
        # read at runtime by auto-update wrapper script — no restart needed
        restartServices = [];
      };
      pushoverBackupToken = {
        path = "/run/opnix/pushover-backup-token";
        reference = "op://nix_secrets/Pushover/nauvooBackup";
        owner = "root";
        group = "root";
        mode = "0600";
        # read at runtime by backup script — no restart needed
        restartServices = [];
      };
      truenasApiKey = {
        path = "/run/opnix/truenas-api-key";
        reference = "op://nix_secrets/truenas/apikey";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["homepage-env-setup.service" "homepage.service"];
      };
      truenasPrivateKey = {
        path = "/run/opnix/truenas-private-key";
        reference = "op://nix_secrets/truenas/private key";
        owner = "root";
        group = "root";
        mode = "0600";
        # read at runtime by backup rsync — no restart needed
        restartServices = [];
      };
      mealieEnv = {
        path = "/run/opnix/mealie-env";
        reference = "op://nix_secrets/mealie/env";
        owner = "root";
        group = "root";
        mode = "0600";
        restartServices = ["mealie.service"];
      };

      # TODO: Fill in correct op:// references before enabling iDRAC fan controller
      # idracIp1 = {
      #   path = "/run/opnix/idrac-ip-1";
      #   reference = "op://nix_secrets/idrac/<field>";
      #   owner = "root";
      #   group = "root";
      #   mode = "0600";
      # };
      # idracIp2 = {
      #   path = "/run/opnix/idrac-ip-2";
      #   reference = "op://nix_secrets/idrac/<field>";
      #   owner = "root";
      #   group = "root";
      #   mode = "0600";
      # };

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
