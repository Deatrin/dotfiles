final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  plexRaw = prev.plexRaw.overrideAttrs (_old: rec {
    version = "1.43.3.10896-cb3ebc72d";
    src = prev.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-qgnyZt3PQI4Qz3ulYbbkVObhCbqUFjlraWW9THnzcUk=";
    };
  });
}
