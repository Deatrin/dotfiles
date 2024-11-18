{
  config,
  pkgs,
  ...
}: {
  enable = true;
  lfs.enable = true;
  userName = "Deatrin";
  userEmail = "jennexa@gmail.com";
  signing.key = "0xAA7FEB9A60111FBC";
  signing.signByDefault = true;

  extraConfig = {
    pull = {
      rebase = true;
    };
    init = {
      defaultBranch = "main";
    };
  };
}
