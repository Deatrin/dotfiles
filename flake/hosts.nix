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
    donnager = {
      system = "x86_64-darwin";
      user = "ajennex";
      modules = [../hosts/darwin/donnager];
    };
    tynan = {
      system = "aarch64-darwin";
      user = "deatrin";
      modules = [../hosts/darwin/tynan];
    };
  };

  homeConfigs = {
    "deatrin@nauvoo" = {
      system = "x86_64-linux";
      modules = [../home-manager/nixos/deatrin_nauvoo.nix];
    };
    "deatrin@tycho" = {
      system = "x86_64-linux";
      modules = [../home-manager/nixos/deatrin_tycho.nix];
    };
    "deatrin@artemis" = {
      system = "x86_64-linux";
      modules = [../home-manager/nixos/deatrin_artemis.nix];
    };
    "ajennex@donnager" = {
      system = "x86_64-darwin";
      modules = [../home-manager/darwin/donnager.nix];
    };
    "deatrin@tynan" = {
      system = "aarch64-darwin";
      modules = [../home-manager/darwin/tynan.nix];
    };
  };
}
