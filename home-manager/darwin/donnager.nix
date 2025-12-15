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
    ../common/features/cli/ghostty_mac.nix
    ../common/features/dev
    ../common/features/kubernetes
  ];

  home = {
    username = lib.mkDefault "ajennex";
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
  };

  home.packages = with pkgs; [
    terminal-notifier # send notifications to macOS notification center
  ];
}
