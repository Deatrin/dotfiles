{...}: {
  services.openssh = {
    enable = true;
    allowSFTP = true;
    # ports = [2222];
    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
      # Allow X11 forwarding
      X11Forwarding = true;
    };
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.sshAgentAuth.enable = true;
}
