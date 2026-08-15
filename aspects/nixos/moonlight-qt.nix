{
  flake.modules.nixos.moonlight-qt = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.moonlight-qt;
  in {
    options.dotfiles.moonlight-qt.enable = lib.mkEnableOption "Moonlight game streaming client";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [
        (pkgs.unstable.moonlight-qt.override { ffmpeg = pkgs.unstable.ffmpeg_7; })
      ];
    };
  };
}
