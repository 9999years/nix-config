{ stdenvNoCC, fetchurl, imagemagick7, ... }:
stdenvNoCC.mkDerivation {
  name = "rbt-background-image";
  version = "1.0.0";
  src = fetchurl {
    url = "https://live.staticflickr.com/809/40680910775_c1eb714fc9_o_d.jpg";
    sha512 =
      "04brp4br5sya6l9d2n35apzp7m63wm40hsddh4dcdbaqfqw511wj68zr1gaj9dzfbvfy9r4da8fxccrnqvlwh97dxxx7ghzrdn2zw0c";
    name = "night-stars.jpg";
  };

  dontUnpack = true;
  dontConfigure = true;
  nativeBuildInputs = [ imagemagick7 ];
  buildPhase = ''
    ${imagemagick7}/bin/magick convert "$src" \
                               -resize 3840 \
                               -quality 90 \
                               night-stars.jpg
  '';
  installPhase = ''
    install -D -m 644 night-stars.jpg "$out/share/wallpapers/night-stars.jpg"
  '';
  dontFixup = true;
}
