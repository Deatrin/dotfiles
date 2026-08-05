{
  flake.modules.nixos.ouro-go = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.dotfiles.ouro-go;
  in {
    options.dotfiles.ouro-go.enable = lib.mkEnableOption "Ouro Discord bot";

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/ouro-go 0755 root root -"
      ];

      # Authenticate Podman to the private Forgejo registry once on boot.
      # Credentials are cached in /root/.config/containers/auth.json (persists across reboots)
      # so autoUpdate pulls also succeed without re-running this service.
      systemd.services.ouro-registry-login = {
        description = "Login to Forgejo container registry for ouro";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "5s";
          ExecStart = pkgs.writeShellScript "forgejo-registry-login" ''
            ${pkgs.podman}/bin/podman login forgejo.jennex.dev \
              -u deatrin \
              --password-stdin < /run/opnix/forgejo-registry-pull-token
          '';
        };
      };

      virtualisation.quadlet.containers.ouro = {
        unitConfig = {
          # Registry login is only needed to pull the image (autoUpdate handles that
          # separately) - the container starts fine from the local cached image even
          # if the login races DNS/network at boot, so only order after it, don't
          # hard-require it.
          After = ["opnix-secrets.service" "ouro-registry-login.service"];
          Requires = ["opnix-secrets.service"];
        };
        containerConfig = {
          image = "forgejo.jennex.dev/deatrin/ouro:latest";
          autoUpdate = "registry";
          environmentFiles = ["/run/opnix/ouro-env"];
          environments = {
            BOT_TZ = "America/Los_Angeles";
            DB_PATH = "/data/ourobantz.db";
          };
          volumes = ["/var/lib/ouro-go:/data"];
        };
      };
    };
  };
}
