{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    brews = [
      "hugo"
      "mise"
    ];
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
