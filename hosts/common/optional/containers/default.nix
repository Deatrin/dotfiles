# Container modules — import this file to enable all containers,
# or import individual service directories as needed.
{...}: {
  imports = [
    ./networks.nix
    ./arr-stack
    ./audiobookshelf
    ./calibre
    #    ./ddns
    ./forgejo
    ./grocy
    ./homebox
    ./homepage
    ./immich
    ./it-tools
    ./navidrome
    ./paperless
    ./pihole
    ./pocket-id
    ./romm
    ./seerr
    ./traefik
  ];
}
