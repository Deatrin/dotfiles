{
  age = {
    secrets = {
      # secret1 = {
      #   file = ../../secrets/secret1.age;
      #   # owner = "deatrin";
      #   # mode = "0400";
      #   # path = "/home/deatrin/.secret1";
      # };
      deatrin-secrets = {
        file = ../../secrets/deatrin-secrets.age;
        owner = "deatrin";
      };
      # traefik-secrets = {
      #   file = ../../secrets/traefik.age;
      #   path = "/home/deatrin/docker_volumes/traefik/.env";
      #   owner = "deatrin";
      # };
      # immich-secrets = {
      #   file = ../../secrets/immich.age;
      #   path = "/home/deatrin/docker_volumes/immich/.env";
      #   owner = "deatrin";
      # };
      ddns-secrets = {
        file = ../../secrets/cloudflareddns.age;
        path = "/home/deatrin/docker_volumes/ddns-prod-1/.env";
        owner = "deatrin";
      };
      tailscale-key.file = ../../secrets/tailscale-key.age;
    };
  };
}
