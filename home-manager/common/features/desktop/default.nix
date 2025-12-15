{pkgs, ...}: {
  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    #    ./hyprpanel.nix
    ./rofi.nix
    # ./theme.nix
    ./wayland.nix
  ];
  home.packages = with pkgs; [
    brave
    wttrbar
  ];
}
