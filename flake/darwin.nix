{
  inputs,
  self,
  ...
}: {
  flake = let
    hostData = import ./hosts.nix;
    mkDarwinConfigurations = hosts:
      inputs.nixpkgs.lib.mapAttrs (name: host:
        self.lib.mkDarwin {
          inherit (host) system modules;
        })
      hosts;
  in {
    darwinConfigurations = mkDarwinConfigurations hostData.darwinHosts;
  };
}
