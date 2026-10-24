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

  # Keep workspaces 1-5 in the bar even when empty
  wayland.windowManager.hyprland.settings.workspace = map (n: "${toString n}, monitor:eDP-1, persistent:true") [1 2 3 4 5];

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    packages = with pkgs; [
      nfs-utils
    ];
  };
}
