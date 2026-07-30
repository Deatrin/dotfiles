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
      "android-studio"
      "claude"
      "claude-code"
      "devpod"
      "goland"
      "proton-drive"
      "pycharm"
      "vivaldi"
    ];
    # masApps = {
    #    };
  };
}
