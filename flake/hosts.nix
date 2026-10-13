{
  nixosHosts = {
    nauvoo = {
      system = "x86_64-linux";
      user = "deatrin";
      modules = [../hosts/nixos/nauvoo];
    };
    tycho = {
      system = "x86_64-linux";
      user = "deatrin";
      modules = [../hosts/nixos/tycho];
    };
    artemis = {
      system = "x86_64-linux";
      user = "deatrin";
      modules = [../hosts/nixos/artemis];
    };
  };

  darwinHosts = {
    tynan = {
      system = "aarch64-darwin";
      user = "deatrin";
      modules = [../hosts/darwin/tynan];
    };
    scirocco = {
      system = "aarch64-darwin";
      user = "deatrin";
      modules = [../hosts/darwin/scirocco];
    };
  };

}
