{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-manager
    font-awesome_5
    noto-fonts
  ];
}
