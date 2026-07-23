{
  flake.modules.homeManager.claude = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.claude;
  in {
    options.dotfiles.claude.enable = lib.mkEnableOption "Claude Code CLI";

    config = lib.mkIf cfg.enable {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
      };
    };
  };
}
