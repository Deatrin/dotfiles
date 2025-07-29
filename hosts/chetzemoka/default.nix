{
  config,
  pkgs,
  lib,
  inputs,
  home-manager,
  ...
}: {
  imports = [
    # inputs.agenix.darwinModules.default
    ../common/darwin/defaults.nix
    ./homebrew.nix
    # ./secrets.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/src/dotfiles/hosts/chetzemoka/default.nix";

  networking.hostName = "Chetzemoka";

  system.primaryUser = "ajennex";

  users.users.ajennex = {
    description = "Andrew Jennex";
    home = "/Users/ajennex";
  };

  # Change the location of screenshots
  system.defaults.screencapture.location = "/Users/ajennex/Pictures/Screenshots";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
