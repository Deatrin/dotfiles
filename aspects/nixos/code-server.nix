# Browser-based VS Code, running as the deatrin user so it sees the real
# home directory, dotfiles, and dev environment. Not routed to the internet —
# see hosts/nixos/nauvoo/containers.nix for the Traefik wiring (Tailscale-only
# IP allowlist + Pocket ID forward-auth), and services.code-server.hashedPassword
# set per-host as a fallback layer for anyone already inside the Tailscale range.
{
  flake.modules.nixos.code-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.code-server;
  in {
    options.dotfiles.code-server.enable = lib.mkEnableOption "code-server (browser-based VS Code)";

    config = lib.mkIf cfg.enable {
      services.code-server = {
        enable = true;
        host = "0.0.0.0";
        port = 4444;
        auth = "password";
        user = "deatrin";
        group = "users";
        disableTelemetry = true;
        # Default workspace only — the integrated terminal still has full shell access
        # to the rest of $HOME (dotfiles, signing key, ssh-agent), this just scopes
        # what the file explorer opens to by default.
        extraArguments = ["/home/deatrin/src"];
      };

      # deatrin's home-manager profile (git, jj, nvim, tmux, ...) — a plain string
      # override on environment.PATH conflicts with NixOS's own systemd default, so
      # extend it via the mergeable `path` list instead.
      systemd.services.code-server.path = ["/home/deatrin/.nix-profile/bin"];
    };
  };
}
