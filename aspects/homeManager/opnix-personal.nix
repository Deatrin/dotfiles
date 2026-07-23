{
  flake.modules.homeManager.opnix-personal = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.opnix-personal;
  in {
    options.dotfiles.opnix-personal.enable = lib.mkEnableOption "personal 1Password secrets (opnix)";

    config = lib.mkIf cfg.enable {
      programs.onepassword-secrets = {
        enable = true;
        secrets = {
          # Add personal secrets here
          example = {
            path = ".config/personal-app/.env";
            reference = "op://Darwin Secrets/testenv/text";
            mode = "0600";
          };
        };
      };
    };
  };
}
