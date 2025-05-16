{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "airtool"
      "mixed-in-key"
      "rekordbox"
      "wifi-explorer-pro"
    ];
    # masApps = {
    # };
  };
}
