{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "mixed-in-key"
      "rekordbox"
      "zoom"
    ];
    # masApps = {
    # };
  };
}
