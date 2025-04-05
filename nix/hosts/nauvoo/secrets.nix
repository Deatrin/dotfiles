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
      traefik-secrets = {
        file = ../../secrets/traefik.age;
        path = "/home/deatrin/docker_volumes/traefik/.env";
        owner = "deatrin";
      };
      renovate-secrets = {
        file = ../../secrets/renovate.age;
        path = "/home/deatrin/docker_volumes/renovate/.env";
        owner = "deatrin";
      };
      # immich-secrets = {
      #   file = ../../secrets/immich.age;
      #   path = "/home/deatrin/docker_volumes/immich/.env";
      #   owner = "deatrin";
      # };
    };
  };
}
