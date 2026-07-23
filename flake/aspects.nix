{lib, ...}: {
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = {};
    description = "Dendritic-pattern aspect modules, keyed by configuration class (nixos, darwin, homeManager) then aspect name. Populated by files under aspects/.";
  };
}
