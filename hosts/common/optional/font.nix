{pkgs, ...}: {
  fonts.packages = with pkgs.unstable; [
    nerd-fonts-jetbrains-mono
    nerd-fonts-roboto-mono
    nerd-fonts-noto
    nerd-fonts-monaspace
    nerd-fonts-hack
    nerd-fonts-fira-code
    nerd-fonts-departure-mono
  ];
}
