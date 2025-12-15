{
  inputs,
  self,
  ...
}: {
  flake = let
    hostData = import ./hosts.nix;
    mkNixosConfigurations = hosts:
      inputs.nixpkgs.lib.mapAttrs (name: host:
        self.lib.mkNixos {
          inherit (host) system modules;
        })
      hosts;
  in {
    nixosConfigurations = mkNixosConfigurations hostData.nixosHosts;
  };
}
