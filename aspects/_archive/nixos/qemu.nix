{
  flake.modules.nixos.qemu = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.qemu;
  in {
    options.dotfiles.qemu.enable = lib.mkEnableOption "QEMU guest agent";

    config = lib.mkIf cfg.enable {
      services.qemuGuest.enable = true;
    };
  };
}
