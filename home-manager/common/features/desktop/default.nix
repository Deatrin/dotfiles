{pkgs, ...}: {
  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpanel.nix
    ./rofi.nix
    ./theme.nix
    # ./waybar.nix
  ];
  home.packages = with pkgs; [
    brave
    devpod-desktop
    vivaldi
    wttrbar
  ];
}
