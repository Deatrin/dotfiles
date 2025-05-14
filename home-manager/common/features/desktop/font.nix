{pkgs, ...}: {
  fonts.packages = with pkgs.unstable; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    nerd-fonts.noto
    nerd-fonts.monospace
    nerd-fonts.hack
    nerd-fonts.fira-code
    nerd-fonts.departure-mono
  ];
}
