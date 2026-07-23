{
  flake.modules.nixos.podman = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.podman;
  in {
    options.dotfiles.podman.enable = lib.mkEnableOption "Podman container runtime";

    config = lib.mkIf cfg.enable {
      virtualisation = {
        podman = {
          enable = true;
          dockerCompat = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
            flags = [
              "--filter=until=24h"
              "--filter=label!=important"
            ];
          };
          defaultNetwork.settings.dns_enabled = true;
        };
      };
      environment.systemPackages = with pkgs; [
        podman-compose
      ];
    };
  };
}
