_final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  plexRaw = prev.plexRaw.overrideAttrs (_old: rec {
    version = "1.43.5.11079-b3b13e506";
    src = prev.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-dOmnHJfgbW6SXMQ5gnkUH9g47p30RvkOdpYU+iyHogY=";
    };
  });
}
