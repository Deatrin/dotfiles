{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  taps = [
    "charmbracelet/tap"
  ];
  homebrew = {
    brews = [
      "hugo"
      "mise"
      "age"
      "cloudflared"
      "crush"
    ];
    casks = [
      "airtool"
      "wifi-explorer-pro"
    ];
    # masApps = {
    # };
  };
}
