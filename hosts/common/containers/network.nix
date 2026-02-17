{...}: {
  virtualisation.quadlet.networks.traefik-network = {
    networkConfig = {
      driver = "bridge";
    };
  };
}
