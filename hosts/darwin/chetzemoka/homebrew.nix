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
      "wifi-explorer-pro"
      "claude"
      "claude-code"
    ];
    masApps = {
      "Good Notes 6" = 1444383602;
    };
  };
}
