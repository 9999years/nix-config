{ stdenv, fetchurl, ... }:
stdenv.mkDerivation rec {
  name = "psftools";
  version = "0.5.1";

  src = fetchurl {
    url = "https://tset.de/downloads/psftools-0.5.1.tar.gz";
    sha512 =
      "32v3w3kcb5gwsaividljn0j11jgfxmz4igpywz23z2q1iqjdx041dh38xm3am50fxahxkc8wsa791i2fmi919rdywhaslizav8w04p2";
  };

  preInstall = ''
    BINDIR="$out/bin"
    CONSOLEFONTDIR="$out/share/consolefonts"
    mkdir -p $BINDIR $CONSOLEFONTDIR
    export MAKEFLAGS="BINDIR=$BINDIR CONSOLEFONTDIR=$CONSOLEFONTDIR"
  '';
}
