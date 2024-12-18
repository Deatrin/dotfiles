{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./theme.nix
    ./wayland.nix
    ./wofi.nix
  ];

  home.packages = with pkgs; [
  ];
}
