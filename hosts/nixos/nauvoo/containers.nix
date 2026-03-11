# Nauvoo container imports — uncomment services one at a time as they're migrated.
#
# When enabling forgejo, also uncomment its settings below.
{ ... }: {
  imports = [
    ../../common/optional/quadlet.nix
    ../../common/optional/containers/networks.nix
    ../../common/optional/containers/traefik
    ../../common/optional/containers/pihole
    ../../common/optional/containers/homepage
    ../../common/optional/containers/it-tools
    ../../common/optional/containers/grocy
    ../../common/optional/containers/homebox
    ../../common/optional/containers/navidrome
    ../../common/optional/containers/audiobookshelf
    ../../common/optional/containers/calibre
    ../../common/optional/containers/pocket-id
    ../../common/optional/containers/romm
    ../../common/optional/containers/paperless
    ../../common/optional/containers/immich
    ../../common/optional/containers/forgejo  # also uncomment forgejo settings below
    ../../common/optional/containers/arr-stack
    ../../common/optional/containers/seerr
    # ../../common/optional/containers/ddns
    # ../../common/optional/containers/idrac
  ];

  # Nauvoo-specific container settings
  services.pihole-quadlet.dnsListenIP = "10.1.30.100";

  # External services proxied through Traefik
  services.traefik-quadlet.externalServices = [
    {
      name = "plex";
      hostname = "plex.jennex.dev";
      url = "http://10.1.30.100:32400";
    }
  ];

  # DNS overrides — bypass Traefik, resolve directly to the service IP
  services.pihole-quadlet.dnsOverrides = [
    { hostname = "idrac-proxmox.jennex.dev"; ip = "10.1.20.10"; }
    { hostname = "idrac-truenas.jennex.dev"; ip = "10.1.20.15"; }
  ];

  # Forgejo settings — uncomment alongside the forgejo import above
  services.forgejo-quadlet.sshPort = 22;
  services.forgejo-quadlet.dataPath = "/ssdstorage/forgejo";
}
