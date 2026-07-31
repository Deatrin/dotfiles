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
}
