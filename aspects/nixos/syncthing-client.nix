# Native Syncthing desktop client (nixpkgs' services.syncthing module), for
# hosts that pair as a peer over Syncthing's P2P protocol via a local GUI --
# e.g. syncing Claude Code's per-project memory files between machines (see
# aspects/homeManager/claude.nix's memorySync option).
#
# Distinct from `dotfiles.syncthing` (aspects/nixos/containers/syncthing.nix)
# -- that's nauvoo's headless Quadlet-container hub, reverse-proxied through
# Traefik. Wrong shape for a desktop with a local screen; hence a separate
# name here, paralleling attic-server/attic-client.
#
# Devices and folders are paired by hand through the web GUI at :8384 --
# same convention tynan/scirocco already use for their launchd-managed
# Syncthing (see hosts/darwin/tynan/default.nix). Nothing declarative here.
{
  flake.modules.nixos.syncthing-client = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.syncthing-client;
  in {
    options.dotfiles.syncthing-client.enable =
      lib.mkEnableOption "Syncthing desktop client (native service, GUI-paired devices/folders)";

    config = lib.mkIf cfg.enable {
      services.syncthing = {
        enable = true;
        user = "deatrin";
        group = "users";
        dataDir = "/home/deatrin/.local/share/syncthing";
        configDir = "/home/deatrin/.config/syncthing";
        guiAddress = "127.0.0.1:8384";
        overrideDevices = false;
        overrideFolders = false;
      };

      # Matches nauvoo's existing container precedent (aspects/nixos/containers/syncthing.nix).
      networking.firewall.allowedTCPPorts = [22000];
      networking.firewall.allowedUDPPorts = [22000];
    };
  };
}
