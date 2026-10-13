# Homebrew role: JetBrains IDEs. DataGrip is deliberately not here — it stays in
# tynan's own homebrew.nix so enabling this role doesn't add it to other Macs.
{
  flake.modules.darwin.jetbrains = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.jetbrains;
  in {
    options.dotfiles.jetbrains.enable = lib.mkEnableOption "JetBrains IDEs (Homebrew)";

    config = lib.mkIf cfg.enable {
      homebrew.casks = [
        "goland"
        "pycharm"
      ];
    };
  };
}
