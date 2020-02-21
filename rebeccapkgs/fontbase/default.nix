{ appimage, fetchurl, ... }:

appimage.installAppImage rec {
  name = "FontBase";
  version = "2.10.3";
  src = fetchurl {
    url = "https://releases.fontba.se/linux/${name}-${version}.AppImage";
    sha512 =
      "2p1jvd75a4nc5v0h1hdnnnq76lf703jszyf8ljag8zwdsf2y09yvqfmn5sahmz9z03i3iyzczvrdrg0kw28si9nx6bxw2g9v0rsxa11";
  };
  bin = "fontbase";
}
