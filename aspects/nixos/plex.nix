{
  flake.modules.nixos.plex = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.plex;
  in {
    options.dotfiles.plex.enable = lib.mkEnableOption "Plex media server";

    # use this to claim a new server
    # curl -X POST 'http://127.0.0.1:32400/myplex/claim?token=claim-xxxxxxx'
    config = lib.mkIf cfg.enable {
      services.plex = {
        enable = true;
        openFirewall = true;
        package = pkgs.plex;
        dataDir = "/var/lib/plex";
      };
    };
  };
}
