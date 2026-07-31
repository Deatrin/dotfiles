{
  config,
  pkgs,
  ...
}: {
  programs.jujutsu = {
    enable = true;
    package = pkgs.unstable.jujutsu;
    settings = {
      user.name = "Deatrin";
      user.email = "jennexa@gmail.com";
      signing.backend = "ssh";
      signing.behavior = "own";
      signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdV7xPZWsMYD/bPGyrN+o+/5Fs72LmezBHnkenkYD5i";
      signing.backends.ssh.program =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "${pkgs._1password-gui}/bin/op-ssh-sign";
      git.sign-on-push = true;
    };
  };
}
