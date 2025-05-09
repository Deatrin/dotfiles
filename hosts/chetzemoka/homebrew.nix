{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "airtool"
      "google-chrome"
      "discord"
      "microsoft-office"
      "mixed-in-key"
      "rekordbox"
      "wifi-explorer-pro"
      "slack"
    ];
    masApps = {
      "WireGuard" = 1451685025;
      "Spark Classic" = 1176895641;
    };
  };
}
