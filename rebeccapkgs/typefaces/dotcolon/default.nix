{ stdenv, symlinkJoin, fetchfont, callPackage }:
symlinkJoin rec {
  name = "dotcolon-typefaces";
  version = "2020-10-22";
  paths = map (src:
    fetchfont {
      inherit src version;
      inherit (src) name;
    }) (callPackage ./srcs.nix { });

  meta = with stdenv.lib; { # https://nixos.org/manual/nixpkgs/stable/#chap-meta
    description = "Dot Colon typefaces";
    homepage = "http://dotcolon.net/";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
