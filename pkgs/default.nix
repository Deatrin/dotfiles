# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs }:
{
  # example = pkgs.callPackage ./example { };
  kubectl-browse-pvc = pkgs.callPackage ./kubectl-browse-pvc.nix {};
}
// pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
  plex = pkgs.callPackage ./plex.nix {};
}