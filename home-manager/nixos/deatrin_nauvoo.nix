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

  # nauvoo is headless, so there's no 1Password GUI/agent to sign commits or
  # authenticate with — a dedicated key (not the shared 1Password-vaulted
  # identity key) is delivered here instead, held in a plain ssh-agent.
  # Public half lives in hosts/nixos/nauvoo/default.nix (authorizedKeys) and
  # home-manager/common/features/cli/git.nix (allowed_signers).
  programs.onepassword-secrets = {
    enable = true;
    secrets.nauvooRemoteKey = {
      path = ".ssh/nauvoo_remote_ed25519";
      reference = "op://nix_secrets/nauvoo_key/private key";
      mode = "0600";
    };
  };

  services.ssh-agent.enable = true;

  programs.git.signing = {
    key = lib.mkForce "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7UrapQ7YzEmhaI1pMWaqKMY8tAsX1z4a858Gn4/v+V";
    signer = lib.mkForce "${pkgs.openssh}/bin/ssh-keygen";
  };

  programs.jujutsu.settings.signing = {
    key = lib.mkForce "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7UrapQ7YzEmhaI1pMWaqKMY8tAsX1z4a858Gn4/v+V";
    backends.ssh.program = lib.mkForce "${pkgs.openssh}/bin/ssh-keygen";
  };

  programs.zsh.initContent = ''
    # Load the dedicated nauvoo remote-dev/signing key once per agent lifetime
    if [ -S "$SSH_AUTH_SOCK" ]; then
      ssh-add -l >/dev/null 2>&1
      if [ $? -eq 1 ]; then
        ssh-add "$HOME/.ssh/nauvoo_remote_ed25519" 2>/dev/null
      fi
    fi
  '';
}
