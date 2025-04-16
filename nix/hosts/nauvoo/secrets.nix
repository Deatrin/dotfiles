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
      homepage-secrets = {
        file = ../../secrets/homepage.age;
        path = "/home/deatrin/docker_volumes/homepage-prod-1/.env";
        owner = "deatrin";
      };
    };
  };
}