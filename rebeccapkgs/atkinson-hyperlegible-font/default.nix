{ stdenv, lib, fetchzip }:
stdenv.mkDerivation {
  pname = "atkinson-hyperlegible-font";
  version = "2020-0514";
  src = fetchzip {
    url =
      "https://www.brailleinstitute.org/wp-content/uploads/atkinson-hyperlegible-font/Atkinson-Hyperlegible-Font-Print-and-Web-2020-0514.zip";
    sha256 = "0ik26l52kz3ml1f3pcl8k3jm0ygq49sd8dk4hfwy1a49czmlyvr0";
  };
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,eot,svg,truetype,woff,woff2}
    cp Print\ Fonts/* $out/share/fonts/opentype
    pushd Web\ Fonts || return 1
    cp EOT/* $out/share/fonts/eot
    cp SVG/* $out/share/fonts/svg
    cp TTF/* $out/share/fonts/truetype
    cp WOFF/* $out/share/fonts/woff
    cp WOFF2/* $out/share/fonts/woff2
  '';

  meta = with stdenv.lib; { # https://nixos.org/manual/nixpkgs/stable/#chap-meta
    description =
      "A typeface offering greater legibility and readability for low vision readers";
    longDescription = ''
      Atkinson Hyperlegible font is named after Braille Institute founder, J.
      Robert Atkinson.  What makes it different from traditional typography
      design is that it focuses on letterform distinction to increase character
      recognition, ultimately improving readability.

      Atkinson Hyperlegible differentiates common misinterpreted letters and
      numbers using various design techniques:

      - Four fonts, including two weights (regular, bold, italics, italics
        bold)
      - 1,340 total glyphs across all fonts, 335 per font
      - Accent characters supporting 27 languages
      - For designers and anyone interested in making written materials easier
        to read across the entire visual-ability spectrum
      - Improve legibility and readability for low vision readers
    '';
    homepage = "https://www.brailleinstitute.org/freefont";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
