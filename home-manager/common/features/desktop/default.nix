{pkgs, ...}: {
  imports = [
    ./hyprland.nix
    ./hyprpanel.nix
    ./rofi.nix
    # ./theme.nix
    ./wayland.nix
  ];
  home.packages = with pkgs; [
    brave
    wttrbar
  ];
}
