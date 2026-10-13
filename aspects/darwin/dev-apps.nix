# Homebrew role: general development apps and CLIs. Installed via Homebrew rather
# than nixpkgs, same as the rest of the per-host Homebrew extras.
{
  flake.modules.darwin.dev-apps = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.dev-apps;
  in {
    options.dotfiles.dev-apps.enable = lib.mkEnableOption "development apps and CLIs (Homebrew)";

    config = lib.mkIf cfg.enable {
      homebrew.brews = [
        "hugo"
        "mise"
        "age"
        "cloudflared"
        "opencode"
      ];
      homebrew.casks = [
        "android-studio"
        "claude"
        "claude-code"
        "devpod"
      ];
    };
  };
}
