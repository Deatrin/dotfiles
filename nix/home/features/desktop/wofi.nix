{
  pkgs,
  outputs,
  ...
}: {
  home.packages = [pkgs.wofi pkgs.bemoji pkgs.wofi-pass];
}