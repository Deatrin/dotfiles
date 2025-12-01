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
    };

    signing.key = "0xAA7FEB9A60111FBC";
    signing.signByDefault = true;

    settings = {
      pull = {
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
