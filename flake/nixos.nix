{
  inputs,
  self,
  config,
  ...
}: {
  flake = let
    hostData = import ./hosts.nix;
    aspectModules = builtins.attrValues config.flake.modules.nixos;
    mkNixosConfigurations = hosts:
      inputs.nixpkgs.lib.mapAttrs (name: host:
        self.lib.mkNixos {
          inherit (host) system;
          # quadlet-nix is imported universally (schema only — it declares
          # virtualisation.quadlet.* options without side effects) so that
          # container aspects' option paths resolve on every host, even ones
          # that never define any virtualisation.quadlet.containers.
          modules = host.modules ++ aspectModules ++ [inputs.quadlet-nix.nixosModules.quadlet];
        })
      hosts;
  in {
    nixosConfigurations = mkNixosConfigurations hostData.nixosHosts;
  };
}
