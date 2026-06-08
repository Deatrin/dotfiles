final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  plexRaw = prev.plexRaw.overrideAttrs (_old: rec {
    version = "1.43.2.10687-563d026ea";
    src = prev.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-dgkj0Uny/d0DnExgYWjxfl2cFsiattlGzb7Guzmtro4=";
    };
  });
}
