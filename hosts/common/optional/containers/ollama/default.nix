# Ollama — LLM inference server with NVIDIA GPU
#
# GPU: NVIDIA via CDI (hardware.nvidia-container-toolkit.enable = true)
# Models stored at /ssdstorage/ollama (fast SSD storage)
#
# Routing:
#   ollama.jennex.dev → Ollama API (port 11434, no auth — internal/Tailscale access)
{config, ...}: let
  inherit (config.virtualisation.quadlet) networks;
in {
  systemd.tmpfiles.rules = [
    "d /ssdstorage/ollama 0755 root root -"
  ];

  virtualisation.quadlet = {
    networks.ollama_network = {};

    containers.ollama = {
      containerConfig = {
        image = "docker.io/ollama/ollama:latest";
        autoUpdate = "registry";
        networks = [networks.traefik_network.ref networks.ollama_network.ref];
        volumes = ["/ssdstorage/ollama:/root/.ollama"];
        environments = {
          OLLAMA_HOST = "0.0.0.0";
        };
        podmanArgs = ["--device=nvidia.com/gpu=all"];
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.ollama.rule=Host(`ollama.jennex.dev`)"
          "traefik.http.routers.ollama-secure.entrypoints=https"
          "traefik.http.routers.ollama-secure.rule=Host(`ollama.jennex.dev`)"
          "traefik.http.routers.ollama-secure.tls=true"
          "traefik.http.services.ollama.loadbalancer.server.port=11434"
        ];
      };
    };
  };
}
