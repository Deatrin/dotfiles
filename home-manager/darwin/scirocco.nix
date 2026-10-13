{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ../common/global
  ];

  dotfiles = {
    aerospace.enable = true;
    claude.statusLine.enable = true;
    ghostty.enable = true;
    opnix-personal.enable = true;
    dev.enable = true;
    kubernetes.enable = true;
    opencode.enable = true;
  };

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
  };

  home.packages = with pkgs; [
    terminal-notifier # send notifications to macOS notification center
  ];
}
