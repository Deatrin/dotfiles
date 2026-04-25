# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
    plexRaw = prev.plexRaw.overrideAttrs (_old: rec {
      version = "1.43.1.10611-1e34174b1";
      src = prev.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "sha256-pr1+VSObX0sBl/AddeG/+2dIbNdc+EtnvCzy4nTXVn8=";
      };
    });
  } // {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    # # nota-bene: this doesn't actually build, it fails with "/build/source/go.mod:3: invalid go version '1.21.0': must match format 1.23""

    # # Override default nodejs with nodejs_22
    # # https://github.com/NixOS/nixpkgs/issues/402079
    # nodejs = prev.nodejs_22;
    # nodejs-slim = prev.nodejs-slim_22;

    # Fix direnv fish test getting SIGKILL'd in the macOS Nix sandbox
    direnv = prev.direnv.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });

    # openldap test017-syncreplication-refresh is a flaky timing-dependent test
    # that fails in the Nix sandbox on i686-linux (triggered by lutris dep chain).
    # Must override both the top-level attr and pkgsi686Linux (separate sub-pkgset).
    openldap = prev.openldap.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
    pkgsi686Linux = prev.pkgsi686Linux.extend (_: prev686: {
      openldap = prev686.openldap.overrideAttrs (_: { doCheck = false; });
    });

    # Fix inetutils build on macOS with newer clang
    # https://github.com/NixOS/nixpkgs/issues/XXX
    inetutils = prev.inetutils.overrideAttrs (oldAttrs: {
      env = (oldAttrs.env or {}) // {
        NIX_CFLAGS_COMPILE = (oldAttrs.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error=format-security";
      };
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
      overlays = [
        # Propagate the pkgsi686Linux openldap fix so unstable.lutris builds cleanly
        (_: uprev: {
          pkgsi686Linux = uprev.pkgsi686Linux.extend (_: prev686: {
            openldap = prev686.openldap.overrideAttrs (_: { doCheck = false; });
          });
        })
      ];
    };
  };

  # Add talhelper overlay
  talhelper-overlay = final: _prev: {
    inherit (inputs.talhelper.packages.${final.stdenv.hostPlatform.system}) talhelper;
  };
}
