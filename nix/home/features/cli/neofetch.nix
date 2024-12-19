{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.neofetch;
in {
  options.features.cli.neofetch.enable = mkEnableOption "enable nerofetch";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [neofetch];
  };
}