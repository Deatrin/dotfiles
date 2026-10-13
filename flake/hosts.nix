{
  nixosHosts = {
    nauvoo = {
      system = "x86_64-linux";
      modules = [../hosts/nixos/nauvoo];
    };
    tycho = {
      system = "x86_64-linux";
      modules = [../hosts/nixos/tycho];
    };
    artemis = {
      system = "x86_64-linux";
      modules = [../hosts/nixos/artemis];
    };
  };

  darwinHosts = {
    tynan = {
      system = "aarch64-darwin";
      modules = [../hosts/darwin/tynan];
    };
    scirocco = {
      system = "aarch64-darwin";
      modules = [../hosts/darwin/scirocco];
    };
  };
}
