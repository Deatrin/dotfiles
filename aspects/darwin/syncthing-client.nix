# Syncthing desktop client on macOS, run as a per-user launchd agent
# (nix-darwin has no services.syncthing module). The Darwin counterpart of
# aspects/nixos/syncthing-client.nix — devices and folders are paired by hand
# through the web GUI at :8384, nothing declarative here.
{
  flake.modules.darwin.syncthing-client = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.syncthing-client;
    home = "/Users/${config.system.primaryUser}";
  in {
    options.dotfiles.syncthing-client.enable = lib.mkEnableOption "Syncthing desktop client (launchd user agent)";

    config = lib.mkIf cfg.enable {
      launchd.user.agents.syncthing = {
        serviceConfig = {
          ProgramArguments = [
            "${pkgs.syncthing}/bin/syncthing"
            "--no-browser"
            "--no-restart"
            "--logflags=0"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "${home}/Library/Logs/syncthing.log";
          StandardErrorPath = "${home}/Library/Logs/syncthing-err.log";
        };
      };
    };
  };
}
