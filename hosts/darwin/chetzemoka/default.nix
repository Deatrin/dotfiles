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
    ../../common/darwin/defaults.nix
    ./homebrew.nix
    # ./secrets.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/src/dotfiles/hosts/darwin/chetzemoka/default.nix";

  networking.hostName = "Chetzemoka";

  system.primaryUser = "ajennex";

  users.users.ajennex = {
    description = "Andrew Jennex";
    home = "/Users/ajennex";
  };

  home-manager.users.ajennex = import ../../../home-manager/darwin/chetzemoka.nix;

  # Change the location of screenshots
  system.defaults.screencapture.location = "/Users/ajennex/Pictures/Screenshots";
  system.defaults.dock.persistent-apps = [
    "/Applications/TickTick.app"
    "/Applications/Notion.app"
    "/Applications/Canary Mail.app"
    "/Applications/Brave Browser.app"
    "/System/Applications/Messages.app"
    "/Applications/Raindrop.io.app"
    "/Applications/1Password.app"
    "/Applications/Discord.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/OrbStack.app"
    "/Applications/Termius.app"
    "/Applications/Ghostty.app"
    "/Applications/Spotify.app"
    "/Applications/rekordbox 7/rekordbox.app"
    "/Applications/Mixed In Key 11.app"
    "/System/Applications/App Store.app"
    "/System/Applications/System Settings.app"
    "/Applications/Yubico Authenticator.app"
    "/System/Applications/iPhone Mirroring.app"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
