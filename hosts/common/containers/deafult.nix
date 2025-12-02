{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common/containers/arr-stack/docker-compose.nix
  ];
}
