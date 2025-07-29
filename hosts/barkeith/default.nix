{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  imports = [
    ../common/darwin/defaults.nix
    ./homebrew.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/src/dotfiles/hosts/barkeith/default.nix";

  networking.hostName = "Barkeith";

  system.primaryUser = "ajennex";

  users.users.ajennex = {
    description = "Andrew Jennex";
    home = "/Users/ajennex";
  };

  # Change the default location for screenshots.
  system.defaults.screencapture.location = "/Users/ajennex/Pictures/Screenshots";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
