{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./rofi.nix
    ./theme.nix
    ./wayland.nix
  ];
  home.packages = with pkgs; [
    brave
    hyprpanel
  ];
}
