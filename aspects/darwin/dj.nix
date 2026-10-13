# Homebrew role: DJ software.
{
  flake.modules.darwin.dj = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.dj;
  in {
    options.dotfiles.dj.enable = lib.mkEnableOption "DJ apps (Homebrew)";

    config = lib.mkIf cfg.enable {
      homebrew.casks = [
        "rekordbox"
        "mixed-in-key"
      ];
    };
  };
}
