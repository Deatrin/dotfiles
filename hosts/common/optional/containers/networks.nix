# Shared Podman networks (replaces dokploy-network / proxy)
_: {
  virtualisation.quadlet.networks.traefik_network = {
    networkConfig.driver = "bridge";
  };
}
