# Shared Podman networks (replaces dokploy-network / proxy)
{...}: {
  virtualisation.quadlet.networks.traefik_network = {
    networkConfig.driver = "bridge";
  };
}
