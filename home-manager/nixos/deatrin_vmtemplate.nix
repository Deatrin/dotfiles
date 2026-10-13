# Home-manager config for the VMtemplate host. Copy to
# deatrin_<new-hostname>.nix alongside the host (the shared user module loads
# it by hostname) and turn on whatever the host needs.
{
  lib,
  config,
  ...
}: {
  imports = [
    ../common/global
  ];

  # Opt-in features: aspects/homeManager/<name>.nix. Examples:
  #   claude.enable = true;
  #   claude.memorySync.enable = true;   # needs Syncthing on the host
  #   dev.enable = true;
  dotfiles = {};

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    # Same rule as system.stateVersion: the release at first install.
    stateVersion = lib.mkDefault "26.05";
  };
}
