{inputs, ...}: {
  flake.lib = {
    mkNixos = {
      system,
      modules,
      extraSpecialArgs ? {},
    }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs =
          {
            inherit inputs;
            outputs = inputs.self.outputs;
          }
          // extraSpecialArgs;
      };

    mkDarwin = {
      system,
      modules,
      extraSpecialArgs ? {},
    }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system modules;
        specialArgs =
          {
            inherit inputs;
            outputs = inputs.self.outputs;
          }
          // extraSpecialArgs;
      };

    mkHome = {
      system,
      modules,
      extraSpecialArgs ? {},
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        inherit modules;
        extraSpecialArgs =
          {
            inherit inputs;
            outputs = inputs.self.outputs;
          }
          // extraSpecialArgs;
      };
  };
}
