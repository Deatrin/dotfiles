# EdenText — browser-based word processor (.odt/.docx, PDF export)
# https://github.com/stffnb/edentext
#
# Static app served by nginx: no backend, no state, no secrets. Documents
# live in each browser's local storage, never on nauvoo.
{self, ...}: {
  flake.modules.nixos.edentext = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.edentext;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.edentext.enable = lib.mkEnableOption "EdenText word processor";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.containers.edentext = {
        containerConfig = {
          image = "ghcr.io/stffnb/edentext:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          labels = self.lib.webLabels {
            host = "edentext.jennex.dev";
            router = "edentext";
            port = 80;
            homepage = {
              group = "Home";
              name = "EdenText";
              icon = "sh-edentext.png";
              description = "Word Processor";
            };
          };
        };
      };
    };
  };
}
