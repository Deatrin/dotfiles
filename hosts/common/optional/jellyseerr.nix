{
  config,
  lib,
  pkgs,
  ...
}: {
  services.jellyseerr = {
    enable = true;
    package = pkgs.unstable.jellyseerr;
    port = 5055;
  };
}
