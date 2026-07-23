{
  flake.modules.homeManager.dev = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.dev;
  in {
    options.dotfiles.dev.enable = lib.mkEnableOption "development tooling";

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        # cargo # package manager
        # gcc # compiler
        # gnumake
        go
        # pkgs.unstable.nodejs
        # rustc # compiler
      ];
      home.sessionPath = ["$HOME/.cargo/bin"];
    };
  };
}
