{
  flake.modules.nixos.font = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.font;
  in {
    options.dotfiles.font.enable = lib.mkEnableOption "Nerd Font packages";

    config = lib.mkIf cfg.enable {
      fonts.packages = with pkgs.unstable; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.roboto-mono
        nerd-fonts.noto
        nerd-fonts.monaspace
        nerd-fonts.hack
        nerd-fonts.fira-code
        nerd-fonts.departure-mono
      ];
    };
  };
}
