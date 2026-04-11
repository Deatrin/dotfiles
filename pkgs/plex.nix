{
  plexmediaserver,
  plexRaw,
  fetchurl,
}:
plexmediaserver.override {
  plexRaw = plexRaw.overrideAttrs (_old: rec {
    version = "1.43.1.10611-1e34174b1";
    src = fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-pr1+VSObX0sBl/AddeG/+2dIbNdc+EtnvCzy4nTXVn8=";
    };
  });
}
