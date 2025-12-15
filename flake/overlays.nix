{
  inputs,
  self,
  ...
}: {
  flake.overlays = import ../overlays {inherit inputs;};

  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config.allowUnfree = true;
    };

    _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
