{
  flake.modules.nixos.jellyfin = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.jellyfin;
  in {
    options.dotfiles.jellyfin.enable = lib.mkEnableOption "Jellyfin media server";

    config = lib.mkIf cfg.enable {
      services.jellyfin = {
        enable = true;
        openFirewall = true;
        package = pkgs.unstable.jellyfin;
        dataDir = "/var/lib/jellyfin";
      };
    };
  };
}
