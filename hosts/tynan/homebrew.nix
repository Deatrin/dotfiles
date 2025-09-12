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
      "mixed-in-key"
      "rekordbox"
      "wifi-explorer-pro"
    ];
    masApps = {
      "Good Notes 6" = 1444383602;
    };
  };
}
