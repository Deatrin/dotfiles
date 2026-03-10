# Container modules — import this file to enable all containers,
# or import individual service directories as needed.
{...}: {
  imports = [
    ./networks.nix
    ./audiobookshelf
    ./calibre
    #    ./ddns
    ./grocy
    ./homebox
    ./homepage
    ./it-tools
    ./navidrome
    ./paperless
    ./pihole
    ./pocket-id
    ./romm
    ./traefik
  ];
}
