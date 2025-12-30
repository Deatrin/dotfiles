{
  config,
  pkgs,
  ...
}: {
  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.jellyfin;
      dataDir = "/var/lib/jellyfin";
    };
  };
}
