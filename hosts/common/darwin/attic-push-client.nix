# Push client for the self-hosted Attic Nix binary cache on nauvoo (see
# aspects/nixos/attic-server.nix). Complements attic-client.nix (pull-only):
# this additionally pushes this host's own local builds to nauvoo-cache, so
# other aarch64-darwin hosts (or this one, after a GC) can pull them instead
# of rebuilding — e.g. the nvf markdown LSP -> dotnet-sdk source-build chain,
# which is a ~90min cache miss on aarch64-darwin.
#
# Uses a separate, push-only token from the pull netrc (least privilege —
# each host's secrets.nix needs its own `atticPushToken` secret alongside
# atticNetrc). Unlike the NixOS server aspect, nix-daemon on Darwin isn't a
# nix-darwin-managed launchd service (it predates nix-darwin, installed by
# the original Nix installer), so there's no module option to pin its HOME
# env — the hook script exports HOME itself before invoking attic instead.
{
  lib,
  pkgs,
  inputs,
  ...
}: {
  system.activationScripts.extraActivation.text = ''
    mkdir -p /var/root/.config/attic
    cat > /var/root/.config/attic/config.toml <<'EOF'
    default-server = "nauvoo"

    [servers.nauvoo]
    endpoint = "https://cache.jennex.dev/"
    token-file = "/usr/local/var/opnix/secrets/atticPushToken"
    EOF
    chmod 600 /var/root/.config/attic/config.toml
  '';

  nix.settings.post-build-hook = lib.getExe (pkgs.writeShellApplication {
    name = "attic-post-build-hook";
    text = ''
      export HOME=/var/root
      set -f # disable globbing
      export IFS=' '
      # shellcheck disable=SC2086 # intentional word-splitting of OUT_PATHS
      exec ${lib.getExe inputs.attic.packages.${pkgs.system}.attic-client} push nauvoo-cache $OUT_PATHS
    '';
  });
}
