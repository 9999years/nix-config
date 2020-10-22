{ stdenv, callPackage, fetchzip, fetchFromGitLab, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "velvetyne-typefaces";
  version = "2020-10-21";
  srcs = callPackage ./srcs.nix { };
  sourceRoot = ".";
  unpackPhase = ''
    true
  '';

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,eot,svg,truetype,woff,woff2}
    for src in $srcs; do
      find "$src" \
           -name "__MACOSX" -prune \
        -o -iname "documentation" -prune \
        -o -iname "src*" -prune \
        -o -iname "source*" -prune \
        -o -iname "webspecimen" -prune \
        -o -iname "_*" -prune \
        -o ! -name ".*" \
        \( -iname "*.otf" \
        -o -iname "*.eot" \
        -o -iname "*.svg" \
        -o -iname "*.ttf" \
        -o -iname "*.woff" \
        -o -iname "*.woff2" \) \
        -type f \
        -exec cp --update -t $out/share/fonts/ {} +
    done

    cd $out/share/fonts
    mv *.otf opentype/
    mv *.eot eot/
    mv *.svg svg/
    mv *.ttf truetype/
    mv *.woff woff/
    mv *.woff2 woff2/
    find . -type f -executable -exec chmod -x {} +
  '';

  meta = with stdenv.lib; { # https://nixos.org/manual/nixpkgs/stable/#chap-meta
    description = "Velvetyne typefaces";
    homepage = "http://velvetyne.fr/";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
