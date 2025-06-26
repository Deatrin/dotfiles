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
      "zoom"
    ];
    # masApps = {
    # };
  };
}
