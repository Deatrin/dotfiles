{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./common/global
    ./common/features/cli/ghostty.nix
    ./common/features/dev
    ./common/features/desktop
    ./common/features/kubernetes
    inputs.nix-ld-vscode.nixosModules.default
  ];

  programs.onepassword-secrets = {
    enable = true;
    secrets = [
      # {
      #   # Paths are relative to home directory
      #   path = ".ssh/id_rsa";
      #   reference = "op://Personal/ssh-key/private-key";
      # }
      {
        path = ".config/secret-app/token";
        reference = "op://nix_secrets/atuin/username";
      }
    ];
  };

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
