# Pull-only client for the self-hosted Attic Nix binary cache on nauvoo (see
# aspects/nixos/attic-server.nix / attic-client.nix). Enable per host with
# dotfiles.attic-client.enable; hosts without an atticNetrc secret configured
# just leave it off.
#
# Unlike the NixOS client aspect, this needs no wrapper script: the
# atticNetrc opnix secret is expected to already contain the fully-formatted
# netrc content ("machine cache.jennex.dev\npassword <token>\n"), not just
# the bare token — see each host's secrets.nix for the op:// reference.
{
  flake.modules.darwin.attic-client = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.attic-client;
  in {
    options.dotfiles.attic-client.enable = lib.mkEnableOption "pull from the self-hosted Attic Nix binary cache on nauvoo";

    config = lib.mkIf cfg.enable {
      nix.settings = {
        substituters = ["https://cache.jennex.dev/nauvoo-cache"];
        trusted-public-keys = ["nauvoo-cache:+3CAilhri8xJ2ntW2SNk0saFO7X6dMFiTeLqi6jBiaw="];
        netrc-file = "/usr/local/var/opnix/secrets/atticNetrc";
      };
    };
  };
}
