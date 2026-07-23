{
  flake.modules.nixos.salt = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.salt;
  in {
    options.dotfiles.salt.enable = lib.mkEnableOption "SaltStack master";

    config = lib.mkIf cfg.enable {
      services.salt.master.enable = true;
    };
  };
}
