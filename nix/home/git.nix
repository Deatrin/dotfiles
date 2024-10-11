{
  config,
  pkgs,
  ...
}: {
  enable = true;
  lfs.enable = true;
  userName = "Andrew Jennex";
  userEmail = "jennexa@gmail.com";
  # signing.key = null;
  # signing.signByDefault = true;

  extraConfig = {
    pull = {
      rebase = true;
    };
    init = {
      defaultBranch = "main";
    };
  };
}
