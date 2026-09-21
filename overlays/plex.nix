final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  plexRaw = prev.plexRaw.overrideAttrs (_old: rec {
    version = "1.43.4.10903-e5521bd8c";
    src = prev.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-b2ocgzbXeeHyAVGmk0NJiEutb2pmsYorGJuW5Vw7Pts=";
    };
  });
}
