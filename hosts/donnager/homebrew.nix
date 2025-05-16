{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "zoom"
    ];
    # masApps = {
    # };
  };
}
