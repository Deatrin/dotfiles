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
    };
  };
}
