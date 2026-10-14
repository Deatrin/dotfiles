{
  inputs,
  self,
  ...
}: {
  imports = [inputs.nix-topology.flakeModule];

  perSystem = {system, ...}: {
    topology = {
      modules = [
        # Import global topology configuration
        ../topology-config.nix
        # Pass NixOS configurations for auto-extraction
        {
          nixosConfigurations =
            builtins.mapAttrs (_name: value: value)
            (inputs.nixpkgs.lib.filterAttrs
              (_n: v: v.config.nixpkgs.hostPlatform.system == system)
              self.nixosConfigurations);
        }
      ];
    };
  };
}
