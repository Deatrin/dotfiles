# Homebrew role: Wi-Fi survey and packet-capture tools.
{
  flake.modules.darwin.wifi-tools = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.wifi-tools;
  in {
    options.dotfiles.wifi-tools.enable = lib.mkEnableOption "Wi-Fi analysis tools (Homebrew)";

    config = lib.mkIf cfg.enable {
      homebrew.casks = [
        "airtool"
        "wifi-explorer-pro"
      ];
    };
  };
}
