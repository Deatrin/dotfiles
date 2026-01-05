{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh;
    # Set flake path based on platform and user
    flake =
      if pkgs.stdenv.isLinux then
        # All NixOS users use /etc/nixos
        "/etc/nixos"
      else if pkgs.stdenv.isDarwin then
        # Darwin: user-specific dotfiles paths
        if config.home.username == "deatrin" then
          "/Users/deatrin/src/dotfiles"
        else if config.home.username == "ajennex" then
          # TEMPORARY: ajennex hosts will be reimaged soon, this logic can be removed then
          "/Users/ajennex/src/dotfiles"
        else
          # Fallback for any other Darwin users
          "/Users/${config.home.username}/src/dotfiles"
      else
        null; # Unsupported platform

    # Enable automatic garbage collection
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };
}
