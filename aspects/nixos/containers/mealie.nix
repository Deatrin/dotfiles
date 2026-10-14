{self, ...}: {
  flake.modules.nixos.mealie = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.mealie;
    inherit (config.virtualisation.quadlet) networks;
  in {
    options.dotfiles.mealie.enable = lib.mkEnableOption "Mealie recipe manager";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/mealie 0755 root root -"
      ];

      virtualisation.quadlet.containers.mealie = {
        unitConfig = {
          After = ["opnix-secrets.service"];
          Requires = ["opnix-secrets.service"];
        };
        containerConfig = {
          image = "ghcr.io/mealie-recipes/mealie:latest";
          autoUpdate = "registry";
          networks = [networks.traefik_network.ref];
          environments = {
            TZ = "America/Los_Angeles";
            BASE_URL = "https://mealie.jennex.dev";
            ALLOW_SIGNUP = "false";
            OIDC_AUTH_ENABLED = "true";
            OIDC_SIGNUP_TYPE = "sso";
            OIDC_CONFIGURATION_URL = "https://pocket.jennex.dev/.well-known/openid-configuration";
            OIDC_PROVIDER_NAME = "Pocket ID";
            OIDC_AUTO_REDIRECT = "false";
          };
          environmentFiles = ["/run/opnix/mealie-env"];
          volumes = ["/var/lib/mealie:/app/data"];
          labels = self.lib.webLabels {
            host = "mealie.jennex.dev";
            router = "mealie";
            port = 9000;
            homepage = {
              group = "Home";
              name = "Mealie";
              icon = "mealie.png";
              description = "Recipe Manager";
            };
          };
        };
      };
    };
  };
}
