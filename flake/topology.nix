{inputs, self, ...}: {
  imports = [inputs.nix-topology.flakeModule];

  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    topology = {
      modules = [
        # Import global topology configuration
        ../topology-config.nix
        # Pass NixOS configurations for auto-extraction
        {
          nixosConfigurations =
            builtins.mapAttrs (name: value: value)
            (inputs.nixpkgs.lib.filterAttrs
              (n: v: v.config.nixpkgs.hostPlatform.system == system)
              self.nixosConfigurations);
        }
      ];
    };
  };
}
