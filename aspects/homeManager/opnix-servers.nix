{
  flake.modules.homeManager.opnix-servers = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.opnix-servers;
  in {
    options.dotfiles.opnix-servers.enable = lib.mkEnableOption "server 1Password secrets (opnix)";

    config = lib.mkIf cfg.enable {
      programs.onepassword-secrets = {
        enable = true;
        secrets = {
          # Add server secrets here
        };
      };
    };
  };
}
