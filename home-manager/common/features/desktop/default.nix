{pkgs, ...}: {
  imports = [
    ./hyprland.nix
    ./rofi.nix
    # ./theme.nix
    ./wayland.nix
  ];
}
