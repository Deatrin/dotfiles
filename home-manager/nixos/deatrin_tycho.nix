{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../common/global
  ];

  dotfiles = {
    claude.enable = true;
    claude.statusLine.enable = true;
    ghostty.enable = true;
    dev.enable = true;
    desktop.enable = true;
    kubernetes.enable = true;
  };

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    packages = with pkgs; [
      nfs-utils
    ];
  };
}
