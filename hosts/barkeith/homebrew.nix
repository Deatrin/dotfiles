{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "google-chrome"
      "discord"
      "microsoft-office"
      "obs"
      "slack"
    ];
    masApps = {
      "WireGuard" = 1451685025;
      "Spark Classic" = 1176895641;
    };
  };
}
