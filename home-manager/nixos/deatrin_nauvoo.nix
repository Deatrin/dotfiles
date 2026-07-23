{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../common/global
    inputs.nix-ld-vscode.nixosModules.default
  ];

  dotfiles.kubernetes.enable = true;

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    packages = with pkgs; [
      _1password-cli
      nfs-utils
    ];
  };
}
