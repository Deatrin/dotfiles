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
      "mixed-in-key"
      "rekordbox"
      "zwift" # cycling training
    ];
    # masApps = {
    # };
  };
}
