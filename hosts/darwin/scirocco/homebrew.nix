{
  config,
  pkgs,
  ...
}: {
  # scirocco-only Homebrew extras. Shared groups of apps live in the role
  # aspects under aspects/darwin/ (enabled in ./default.nix); the common
  # base list is hosts/common/darwin/homebrew.nix.
  homebrew = {
    casks = [
      "proton-drive"
      "vivaldi"
    ];
  };
}
