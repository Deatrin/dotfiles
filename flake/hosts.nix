{
  nixosHosts = {
    nauvoo = {
      system = "x86_64-linux";
      user = "deatrin";
      modules = [../hosts/nixos/nauvoo];
    };
    razerback = {
      system = "x86_64-linux";
      user = "deatrin";
      modules = [../hosts/nixos/razerback];
    };
    tycho = {
      system = "x86_64-linux";
      user = "deatrin";
      modules = [../hosts/nixos/tycho];
    };
  };

  darwinHosts = {
    barkeith = {
      system = "x86_64-darwin";
      user = "ajennex";
      modules = [../hosts/darwin/barkeith];
    };
    chetzemoka = {
      system = "aarch64-darwin";
      user = "ajennex";
      modules = [../hosts/darwin/chetzemoka];
    };
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
    "deatrin@razerback" = {
      system = "x86_64-linux";
      modules = [../home-manager/nixos/deatrin_razerback.nix];
    };
    "deatrin@tycho" = {
      system = "x86_64-linux";
      modules = [../home-manager/nixos/deatrin_tycho.nix];
    };
    "ajennex@barkeith" = {
      system = "x86_64-darwin";
      modules = [../home-manager/darwin/barkeith.nix];
    };
    "ajennex@chetzemoka" = {
      system = "aarch64-darwin";
      modules = [../home-manager/darwin/chetzemoka.nix];
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
