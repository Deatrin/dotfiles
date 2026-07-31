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

  dotfiles = {
    claude.enable = true;
    ghostty.enable = true;
    opnix-personal.enable = true;
    dev.enable = true;
    desktop.enable = true;
    kubernetes.enable = true;
  };

  #programs.onepassword-secrets = {
  #enable = true;
  #secrets = [
  # {
  #   # Paths are relative to home directory
  #   path = ".ssh/id_rsa";
  #   reference = "op://Personal/ssh-key/private-key";
  # }
  #{
  #path = ".config/secret-app/token1";
  #reference = "op://nix_secrets/atuin/username";
  # }
  #];
  #  };

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    packages = with pkgs; [
      nfs-utils
    ];
  };
}
