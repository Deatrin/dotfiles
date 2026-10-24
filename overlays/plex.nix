_final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  plexRaw = prev.plexRaw.overrideAttrs (_old: rec {
    version = "1.43.5.11029-6bf8af3f0";
    src = prev.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-Vi7flFa+M4okGC+Df+XVMtfnW6ez1fa+olAwg+d2IuE=";
    };
  });
}
