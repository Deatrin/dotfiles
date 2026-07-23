{
  flake.modules.nixos.greetd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.greetd;
  in {
    options.dotfiles.greetd.enable = lib.mkEnableOption "greetd TUI login manager with Hyprland session";

    config = lib.mkIf cfg.enable {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
            user = "greeter";
          };
        };
      };

      environment.systemPackages = with pkgs; [
        tuigreet
      ];
    };
  };
}
