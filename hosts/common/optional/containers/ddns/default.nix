# Cloudflare DDNS
#
# TODO: Wire up opnix secrets before enabling:
#   1. Add ddnsApiKey and ddnsZone to testbed/secrets.nix with correct op:// references
#   2. Uncomment ddns-env-setup service and container below
#   3. Uncomment ./ddns in containers/default.nix
#
# Secrets required (via opnix):
#   /run/opnix/ddns-api-key  — op://nix_secrets/<item>/api_key
#   /run/opnix/ddns-zone     — op://nix_secrets/<item>/zone
{
  pkgs,
  lib,
  ...
}: {
  # TODO: Uncomment when secrets are wired up
  # systemd.services.ddns-env-setup = {
  #   description = "Build DDNS environment file from secrets";
  #   after = ["opnix-secrets.service"];
  #   requires = ["opnix-secrets.service"];
  #   before = ["cloudflare-ddns.service"];
  #   wantedBy = ["cloudflare-ddns.service"];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = lib.getExe (pkgs.writeShellApplication {
  #       name = "ddns-env-setup";
  #       text = ''
  #         {
  #           printf 'API_KEY=%s\n' "$(cat /run/opnix/ddns-api-key)"
  #           printf 'ZONE=%s\n'    "$(cat /run/opnix/ddns-zone)"
  #         } > /run/opnix/ddns-env
  #         chmod 600 /run/opnix/ddns-env
  #       '';
  #     });
  #   };
  # };

  # TODO: Uncomment when secrets are wired up
  # virtualisation.quadlet.containers."cloudflare-ddns" = {
  #   unitConfig = {
  #     After = ["opnix-secrets.service" "ddns-env-setup.service"];
  #     Requires = ["opnix-secrets.service" "ddns-env-setup.service"];
  #   };
  #   containerConfig = {
  #     image = "docker.io/oznu/cloudflare-ddns:latest";
  #     autoUpdate = "registry";
  #     environments = {
  #       SUBDOMAIN = "home";
  #       PROXIED = "true";
  #     };
  #     environmentFiles = ["/run/opnix/ddns-env"];
  #   };
  # };
}
