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
      "devpod"
      "goland"
      "mixed-in-key"
      "pycharm"
      "rekordbox"
      "vivaldi"
      "wifi-explorer-pro"
    ];
    masApps = {
      "Amazon Kindle" = 302584613;
    };
  };
}
