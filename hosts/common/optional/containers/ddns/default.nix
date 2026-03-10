# Cloudflare DDNS
# Requires /run/opnix/ddns-env provisioned by opnix with:
#   API_KEY=<cloudflare api key>
#   ZONE=<zone name>
{...}: {
  virtualisation.quadlet.containers."cloudflare-ddns" = {
    containerConfig = {
      image = "docker.io/oznu/cloudflare-ddns:latest";
      autoUpdate = "registry";
      environments = {
        SUBDOMAIN = "home";
        PROXIED = "true";
      };
      environmentFiles = ["/run/opnix/ddns-env"];
    };
  };
}
