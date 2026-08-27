# Pull-only client for the self-hosted Attic cache on nauvoo (see
# attic-server.nix). Wires the substituter, trusted public key, and a netrc
# file built from a per-host opnix-delivered token. Each host that enables
# this needs its own `atticToken` secret at /run/opnix/attic-token.
{
  flake.modules.nixos.attic-client = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.attic-client;
  in {
    options.dotfiles.attic-client.enable = lib.mkEnableOption "pull from the self-hosted Attic Nix binary cache on nauvoo";

    config = lib.mkIf cfg.enable {
      nix.settings = {
        substituters = ["https://cache.jennex.dev/nauvoo-cache"];
        trusted-public-keys = ["nauvoo-cache:+3CAilhri8xJ2ntW2SNk0saFO7X6dMFiTeLqi6jBiaw="];
        netrc-file = "/run/opnix/attic-netrc";
      };

      # opnix delivers the raw token only, but Nix's netrc-file needs proper
      # "machine <host>\npassword <token>" lines — same wrapping pattern as
      # attic-server-env-setup.service.
      systemd.services.attic-netrc-setup = {
        description = "Build Nix netrc file for the Attic cache";
        after = ["opnix-secrets.service"];
        requires = ["opnix-secrets.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "attic-netrc-setup";
            text = ''
              printf 'machine cache.jennex.dev\npassword %s\n' \
                "$(cat /run/opnix/attic-token)" > /run/opnix/attic-netrc
              chmod 600 /run/opnix/attic-netrc
            '';
          });
        };
      };
    };
  };
}
