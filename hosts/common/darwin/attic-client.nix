# Pull-only client for the self-hosted Attic Nix binary cache on nauvoo (see
# aspects/nixos/attic-server.nix / attic-client.nix). Darwin has no dendritic
# aspect class yet (per CLAUDE.md), so this is a plain shared module — import
# it explicitly per-host rather than via hosts/common/darwin/defaults.nix, so
# hosts without an atticNetrc secret configured (e.g. donnager) aren't affected.
#
# Unlike the NixOS client aspect, this needs no wrapper script: the
# atticNetrc opnix secret is expected to already contain the fully-formatted
# netrc content ("machine cache.jennex.dev\npassword <token>\n"), not just
# the bare token — see each host's secrets.nix for the op:// reference.
{...}: {
  nix.settings = {
    substituters = ["https://cache.jennex.dev/nauvoo-cache"];
    trusted-public-keys = ["nauvoo-cache:+3CAilhri8xJ2ntW2SNk0saFO7X6dMFiTeLqi6jBiaw="];
    netrc-file = "/usr/local/var/opnix/secrets/atticNetrc";
  };
}
