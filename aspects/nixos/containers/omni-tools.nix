# OmniTools — browser-side utilities for images, video, PDF, text, JSON, etc.
# https://github.com/iib0011/omni-tools
#
# Static app served by nginx: files are processed in the browser, nothing is
# uploaded or stored on nauvoo. No state, no secrets.
{self, ...}: {
  flake.modules.nixos.omni-tools = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.omni-tools;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.omni-tools.enable = lib.mkEnableOption "OmniTools container";

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.containers.omni-tools = {
        containerConfig = {
          image = "docker.io/iib0011/omni-tools:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          labels = self.lib.webLabels {
            host = "omni-tools.jennex.dev";
            router = "omni_tools";
            port = 80;
            homepage = {
              group = "Dev & Games";
              name = "OmniTools";
              icon = "omni-tools.png";
              description = "File & Data Tools";
            };
          };
        };
      };
    };
  };
}
