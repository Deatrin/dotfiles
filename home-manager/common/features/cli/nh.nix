{
  config,
  pkgs,
  ...
}: {
  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh;
    # Set flake path based on platform and user
    flake =
      if pkgs.stdenv.isLinux
      then
        # All NixOS users use /etc/nixos
        "/etc/nixos"
      else if pkgs.stdenv.isDarwin
      then
        # Darwin: user-specific dotfiles paths
        "/Users/${config.home.username}/src/dotfiles"
      else null; # Unsupported platform

    # Enable automatic garbage collection
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };
}
