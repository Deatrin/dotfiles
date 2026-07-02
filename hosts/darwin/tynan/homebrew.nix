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
      "opencode"
    ];
    casks = [
      "airtool"
      "android-studio"
      "claude"
      "claude-code"
      "datagrip"
      "devpod"
      "goland"
      "mixed-in-key"
      "proton-drive"
      "pycharm"
      "rekordbox"
      "vivaldi"
      "wifi-explorer-pro"
      "zwift"
    ];
    masApps = {
      "Amazon Kindle" = 302584613;
    };
  };
}
