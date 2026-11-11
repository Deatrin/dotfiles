# Brave, repackaged from upstream's .deb.
#
# nixpkgs removed brave in Nov 2026 ("no committers among its maintainers to
# unblock security issues"), so this vendors the last nixpkgs expression,
# trimmed to Linux (the Macs install brave-browser from Homebrew instead).
#
# Nothing bumps this automatically: run ./update.sh to move to the latest
# upstream release.
{
  stdenv,
  callPackage,
}: let
  version = "1.99.56";

  archives = {
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
      hash = "sha256-W1r00Qh1j+XoK3yxGa8gOXepD8s0ubBzGTF/hj84vHI=";
    };
    aarch64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_arm64.deb";
      hash = "sha256-LOHHJU2azfLo/hV2HkaeMUMidIc8hEh3PbGwukDxhhg=";
    };
  };

  system = stdenv.hostPlatform.system;
  # Lazy throw, so meta (platforms) stays evaluable on unsupported systems.
  unsupported = throw "brave: unsupported platform ${system}";
  fallback = {
    url = unsupported;
    hash = unsupported;
  };
  archive = archives.${system} or fallback;
in
  callPackage ./make-brave.nix {} (archive
    // {
      pname = "brave";
      inherit version;
    })
