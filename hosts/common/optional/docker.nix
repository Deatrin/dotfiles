{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      live-restore = false;
      dns = ["10.1.30.1" "1.1.1.1"];  # Use local DNS first, then fallback to Cloudflare
    };
  };

  # Allow Docker containers to reach the local DNS server
  networking.firewall.trustedInterfaces = ["docker0" "br-+"];
}
