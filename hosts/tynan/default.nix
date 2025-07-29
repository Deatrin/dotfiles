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
  environment.darwinConfig = "$HOME/src/dotfiles/hosts/tynan/default.nix";

  networking.hostName = "Tynan";

  system.primaryUser = "deatrin";

  users.users.deatrin = {
    description = "Andrew Jennex";
    home = "/Users/deatrin";
  };

  # Change the default location for screenshots.
  system.defaults.screencapture.location = "/Users/deatrin/Pictures/Screenshots";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
