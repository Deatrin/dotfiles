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

  # Per system dock
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
    "/Applications/Paprika Recipe Manager 3.app"
    "/System/Applications/App Store.app"
    "/System/Applications/System Settings.app"
    "/Applications/Yubico Authenticator.app"
    "/System/Applications/iPhone Mirroring.app"
  ];
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
