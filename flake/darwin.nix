{
  inputs,
  self,
  config,
  ...
}: {
  flake = let
    hostData = import ./hosts.nix;
    # Every aspects/darwin/*.nix module, appended to every darwin host — each
    # is gated by its own dotfiles.<name>.enable toggle (same as flake/nixos.nix).
    aspectModules = builtins.attrValues (config.flake.modules.darwin or {});
    mkDarwinConfigurations = hosts:
      inputs.nixpkgs.lib.mapAttrs (_name: host:
        self.lib.mkDarwin {
          inherit (host) system;
          modules = host.modules ++ aspectModules;
        })
      hosts;
  in {
    darwinConfigurations = mkDarwinConfigurations hostData.darwinHosts;
  };
}
