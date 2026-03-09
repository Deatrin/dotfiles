{
  config,
  pkgs,
  ...
}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Deatrin";
      user.email = "jennexa@gmail.com";
      signing.backend = "gpg";
      signing.behavior = "own";
      signing.key = "0xAA7FEB9A60111FBC";
      git.sign-on-push = true;
    };
  };
}
