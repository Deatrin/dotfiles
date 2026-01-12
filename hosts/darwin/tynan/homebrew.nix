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
      "claude"
      "claude-code"
      "datagrip"
      "goland"
      "mixed-in-key"
      "pycharm"
      "rekordbox"
      "wifi-explorer-pro"
    ];
    masApps = {
      "Good Notes 6" = 1444383602;
      "Amazon Kindle" = 302584613;
    };
  };
}
