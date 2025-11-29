{
  lib,
  pkgs,
  config,
  ...
}: {
  services.netbox = {
    enable = true;
    package = pkgs.unstable.netbox;
  };
}
