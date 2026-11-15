{
  flake.modules.nixos.greetd = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    cfg = config.dotfiles.greetd;
  in {
    # Imported unconditionally so the option exists; inert unless enabled below.
    imports = [inputs.noctalia-greeter.nixosModules.default];

    options.dotfiles.greetd = {
      enable = lib.mkEnableOption "greetd login manager with Hyprland session";
      greeter = lib.mkOption {
        type = lib.types.enum ["tuigreet" "noctalia"];
        default = "tuigreet";
        description = ''
          tuigreet: TUI greeter launching start-hyprland.
          noctalia: Noctalia Greeter (graphical, wallpaper/palette synced from
          Noctalia via Settings > Security > Noctalia Greeter).
        '';
      };
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        services.greetd.enable = true;
      }

      (lib.mkIf (cfg.greeter == "tuigreet") {
        services.greetd.settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
          user = "greeter";
        };
        environment.systemPackages = [pkgs.tuigreet];
      })

      (lib.mkIf (cfg.greeter == "noctalia") {
        services.displayManager.noctalia-greeter = {
          enable = true;
          passwordless-sync-users = ["deatrin"];
          settings = {
            # hyprland.desktop execs start-hyprland
            session.default = "hyprland";
            user.default = "deatrin";
          };
        };
      })
    ]);
  };
}
