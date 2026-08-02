# Nauvoo container config — every container is a toggle under `dotfiles.<name>.enable`
# (see aspects/nixos/containers/). Only foundational, always-on infra is imported
# directly below; everything else is enabled via the dotfiles block.
{ ... }: {
  imports = [
    ../../common/optional/quadlet.nix
    ../../common/optional/containers/networks.nix
    ../../common/optional/containers/op-connect
    ../../common/optional/containers/traefik
  ];

  dotfiles = {
    it-tools.enable = true;
    drawio.enable = true;
    excalidraw.enable = true;
    kavita.enable = true;
    pihole.enable = true;
    homepage.enable = true;
    grocy.enable = true;
    homebox.enable = true;
    navidrome.enable = true;
    audiobookshelf.enable = true;
    calibre.enable = true;
    pocket-id.enable = true;
    romm.enable = true;
    paperless.enable = true;
    immich.enable = true;
    forgejo.enable = true;
    arr-stack.enable = true;
    seerr.enable = true;
    syncthing.enable = true;
    nextcloud.enable = true;
    manyfold.enable = true;
    traefik-forward-auth.enable = true;
    monitoring.enable = true;
    netbox.enable = true;
    mealie.enable = true;
    netboot.enable = true;
    ollama.enable = true;
    open-webui.enable = true;
    ouro-go.enable = true;
    idrac.enable = true;
    karakeep.enable = true;
    # ddns.enable stays false — secrets not wired up yet (see aspects/nixos/containers/ddns.nix)
  };

  # Nauvoo-specific container settings
  services.pihole-quadlet.dnsListenIP = "10.1.30.100";

  # External services proxied through Traefik
  services.traefik-quadlet.externalServices = [
    {
      name = "plex";
      hostname = "plex.jennex.dev";
      url = "http://10.1.30.100:32400";
    }
    {
      name = "code-server";
      hostname = "code.jennex.dev";
      url = "http://10.1.30.100:4444";
      # Restricted to Tailscale peers, then gated by Pocket ID SSO on top —
      # entrypoints 80/443 are open on the WAN like every other service, so
      # both layers are needed to actually keep this off the public internet.
      middlewares = ["tailscale-only" "forward-auth@docker"];
    }
  ];


  # Forgejo settings
  services.forgejo-quadlet.sshPort = 22;
  services.forgejo-quadlet.dataPath = "/ssdstorage/forgejo";
}
