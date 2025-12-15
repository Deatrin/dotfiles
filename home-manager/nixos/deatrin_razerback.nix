{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../common/global
    ../common/features/cli/ghostty.nix
    #./common/features/dev
    ../common/features/desktop
    ../common/features/kubernetes
    inputs.nix-ld-vscode.nixosModules.default
  ];

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    packages = with pkgs; [
      _1password-gui
      _1password-cli
      nfs-utils
      yubioath-flutter
      yubikey-manager
    ];
  };
}
