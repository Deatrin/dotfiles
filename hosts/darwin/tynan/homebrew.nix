_: {
  # tynan-only Homebrew extras. Shared groups of apps live in the role
  # aspects under aspects/darwin/ (enabled in ./default.nix); the common
  # base list is hosts/common/darwin/homebrew.nix.
  homebrew = {
    casks = [
      "datagrip"
      "prismlauncher"
      "proton-drive"
      "vivaldi"
      "zwift"
    ];
    masApps = {
      "Amazon Kindle" = 302584613;
    };
  };
}
