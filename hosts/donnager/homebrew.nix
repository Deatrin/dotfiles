{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    brews = [
      "mise"
    ];
    casks = [
      "mixed-in-key"
      "rekordbox"
      "zoom"
    ];
    # masApps = {
    # };
  };
}
