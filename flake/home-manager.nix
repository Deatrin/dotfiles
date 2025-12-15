{
  inputs,
  self,
  ...
}: {
  flake = let
    hostData = import ./hosts.nix;
    mkHomeConfigurations = configs:
      inputs.nixpkgs.lib.mapAttrs (name: config:
        self.lib.mkHome {
          inherit (config) system modules;
        })
      configs;
  in {
    homeConfigurations = mkHomeConfigurations hostData.homeConfigs;
  };
}
