{ lib, stdenv, fetchzip, cups }:
stdenv.mkDerivation {
  pname = "star-tsp100-futurePRNT";
  version = "7.4";

  src = fetchzip {
    url =
      "https://www.starmicronics.com/Support/DriverFolder/drvr/tsp100_v740_lite.zip";
    hash = "sha256:113whk25wdn5khr3rm3qfliyg04l9spi0s6wng1asmp6bx86h1xr";
    stripRoot = false;
  };

  unpackPhase = ''
    srcName="$(stripHash $src)"
    cp --recursive $src $srcName
    chmod --recursive +w $srcName
    cd source/Linux/CUPS
    tar -xf ./starcupsdrv-3.7.0_linux.tar.gz
    cd starcupsdrv-3.7.0_linux/SourceCode
    tar -xf ./starcupsdrv-src-3.7.0.tar.gz
    cd starcupsdrv
  '';

  buildInputs = [ cups ];

  preInstall = ''
    export DESTDIR="$out"
    export FILTERDIR="lib/cups/filter"
    export PPDDIR="share/cups/model/star"
  '';
}
