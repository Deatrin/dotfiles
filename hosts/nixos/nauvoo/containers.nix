# Nauvoo container imports — uncomment services one at a time as they're migrated.
#
# When enabling forgejo, also uncomment its settings below.
{ ... }: {
  imports = [
    ../../common/optional/quadlet.nix
    ../../common/optional/containers/networks.nix
    # ../../common/optional/containers/traefik
    # ../../common/optional/containers/pihole
    # ../../common/optional/containers/homepage
    # ../../common/optional/containers/it-tools
    # ../../common/optional/containers/grocy
    # ../../common/optional/containers/homebox
    # ../../common/optional/containers/navidrome
    # ../../common/optional/containers/audiobookshelf
    # ../../common/optional/containers/calibre
    # ../../common/optional/containers/pocket-id
    # ../../common/optional/containers/romm
    # ../../common/optional/containers/paperless
    # ../../common/optional/containers/immich
    # ../../common/optional/containers/forgejo  # also uncomment forgejo settings below
    # ../../common/optional/containers/arr-stack
    # ../../common/optional/containers/seerr
    # ../../common/optional/containers/ddns
    # ../../common/optional/containers/idrac
  ];

  # Forgejo settings — uncomment alongside the forgejo import above
  # services.forgejo-quadlet.sshPort = 22;       # system SSH is on 2222
  # services.forgejo-quadlet.dataPath = "/ssdstorage/forgejo";
}
