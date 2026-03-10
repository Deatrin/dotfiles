{
  lib,
  config,
  ...
}: {
  imports = [
    ../common/global
    ../common/features/cli/opnix_servers.nix
  ];

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.11";
  };
}
