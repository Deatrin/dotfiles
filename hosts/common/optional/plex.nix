{
  config,
  pkgs,
  ...
}: {
  services = {
    plex = {
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.plex;
      dataDir = "/var/lib/plex";
    };
  };
}
# use this to claim a new server
# curl -X POST 'http://127.0.0.1:32400/myplex/claim?token=claim-xxxxxxx'

