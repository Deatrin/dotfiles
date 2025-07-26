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
      "age"
      "cloudflared"
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
