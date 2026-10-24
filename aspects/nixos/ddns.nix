# Cloudflare DDNS — keeps an A record pointed at this host's public IPv4.
#
# Uses nixpkgs' services.cloudflare-ddns (favonia/cloudflare-ddns). Its
# EnvironmentFile carries both secrets, so neither the API token nor the
# Pushover keys end up in the Nix store (the module's `shoutrrr` option would
# put them there).
#
# Secrets (host secrets.nix, op-connect):
#   /run/opnix/cloudflare-ddns-token  — Cloudflare token, Zone:DNS:Edit on the zone
#   /run/opnix/dotfiles-sync-pushover-token, /run/opnix/pushover-user-token
{
  flake.modules.nixos.ddns = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.ddns;
    envFile = "/run/cloudflare-ddns/env";
  in {
    options.dotfiles.ddns = {
      enable = lib.mkEnableOption "Cloudflare DDNS";
      domains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["home.jennex.dev"];
        description = "Records kept pointed at the public IPv4.";
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.cloudflare-ddns-env-setup = {
        description = "Build Cloudflare DDNS environment file from secrets";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        before = ["cloudflare-ddns.service"];
        requiredBy = ["cloudflare-ddns.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          RuntimeDirectory = "cloudflare-ddns";
          RuntimeDirectoryPreserve = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "cloudflare-ddns-env-setup";
            text = ''
              umask 077
              {
                printf 'CLOUDFLARE_API_TOKEN=%s\n' "$(cat /run/opnix/cloudflare-ddns-token)"
                printf 'SHOUTRRR=pushover://shoutrrr:%s@%s/\n' \
                  "$(cat /run/opnix/dotfiles-sync-pushover-token)" \
                  "$(cat /run/opnix/pushover-user-token)"
              } > ${envFile}
            '';
          });
        };
      };

      # systemd reads EnvironmentFile as root before dropping to the service
      # user, so the root-only env file is fine.
      services.cloudflare-ddns = {
        enable = true;
        credentialsFile = envFile;
        inherit (cfg) domains;
        proxied = "false";
        provider.ipv6 = "none"; # no public IPv6 at home
      };
    };
  };
}
