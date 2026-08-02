{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Deatrin";
      user.email = "jennexa@gmail.com";
      pull.rebase = true;
      init.defaultBranch = "main";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdV7xPZWsMYD/bPGyrN+o+/5Fs72LmezBHnkenkYD5i";
      format = "ssh";
      signByDefault = true;
      signer =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "${pkgs._1password-gui}/bin/op-ssh-sign";
    };
  };

  home.file.".ssh/allowed_signers".text = ''
    jennexa@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdV7xPZWsMYD/bPGyrN+o+/5Fs72LmezBHnkenkYD5i
    jennexa@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7UrapQ7YzEmhaI1pMWaqKMY8tAsX1z4a858Gn4/v+V
  '';
}
