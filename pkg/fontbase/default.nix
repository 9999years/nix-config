{ pkgs, ... }:

with pkgs;
stdenv.mkDerivation rec {
  name = "FontBase";
  version = "2.10.3";

  appimageSrc = fetchurl {
    url = "https://releases.fontba.se/linux/${name}-${version}.AppImage";
    sha512 = "2p1jvd75a4nc5v0h1hdnnnq76lf703jszyf8ljag8zwdsf2y09yvqfmn5sahmz9z03i3iyzczvrdrg0kw28si9nx6bxw2g9v0rsxa11";
  };

  appimageExtracted = appimageTools.extractType2 {
    name = "fontbase";
    src = appimageSrc;
  };

  src = appimageTools.wrapType2 {
    name = "fontbase";
    src = appimageSrc;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  buildInputs = [
    xdg_utils
  ];
  installPhase =
    ''
      # Copy the binary
      mkdir -p "$out/bin"
      cp "$src/bin/fontbase" "$out/bin/"

      # Copy the icons
      mkdir -p "$out/share"
      cp -r "$appimageExtracted/usr/share" "$out/"

      # Copy the desktop file and patch it to have the right executable path
      mkdir -p "$out/share/applications"
      cp "$appimageExtracted/fontbase.desktop" "$out/share/applications/"
      substituteInPlace "$out/share/applications/fontbase.desktop" \
                        --replace "Exec=AppRun" "Exec=$out/bin/fontbase"
    '';
}
