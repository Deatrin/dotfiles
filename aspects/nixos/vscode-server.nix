{
  flake.modules.nixos.vscode-server = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.vscode-server;
  in {
    options.dotfiles.vscode-server.enable = lib.mkEnableOption "VS Code Remote-SSH server support";

    config = lib.mkIf cfg.enable {
      programs.nix-ld.enable = true;
      services.openssh.extraConfig = ''
        AcceptEnv is_vscode
      '';
    };
  };
}
