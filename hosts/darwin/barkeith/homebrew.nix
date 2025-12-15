{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "airtool"
      "mtmr"
      "mixed-in-key"
      "rekordbox"
      "wifi-explorer-pro"
    ];
    # masApps = {
    # };
  };
}
