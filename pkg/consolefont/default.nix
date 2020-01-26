{ pkgs ? import <nixpkgs> { }, fontSize ? 32, }:
let outputName = size: "hack-${toString size}";
in with pkgs;
stdenv.mkDerivation rec {
  name = "big-console-font";
  version = "1.0.0";

  roundAvgWidth = ./round_average_width.awk;
  inputFont = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
  srcs = [ inputFont roundAvgWidth ];
  dontUnpack = true;
  dontConfigure = true;
  dontInstall = true;

  nativeBuildInputs = [ (import ./otf2bdf.nix { inherit pkgs; }) bdf2psf ];

  bdfShare = "${bdf2psf}/usr/share/bdf2psf";

  buildPhase = ''
    mkdir -p $out/share/consolefonts/
    cd $out/share/consolefonts/

    # Convert OTF/TTF to BDF:
    otf2bdf -v \
            -r 72 \
            -p "${toString fontSize}" \
            "$inputFont" \
            | awk -f ${roundAvgWidth} \
            > font.bdf

    # Convert BDF to PSF.
    bdf2psf --fb font.bdf \
            ${bdfShare}/standard.equivalents \
            ${bdfShare}/fontsets/Uni2.512 \
            512 \
            font.psf

    rm font.bdf
    gzip font.psf
    mv font.psf.gz "${outputName fontSize}.psf.gz"
  '';
}
