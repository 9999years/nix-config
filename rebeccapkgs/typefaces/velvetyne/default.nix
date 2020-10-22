{ stdenv, symlinkJoin, fetchfont, callPackage }:
symlinkJoin rec {
  name = "velvetyne-typefaces";
  version = "2020-10-21";
  paths = map (src:
    fetchfont {
      inherit src version;
      inherit (src) name;
    }) (callPackage ./srcs.nix { });

  meta = with stdenv.lib; { # https://nixos.org/manual/nixpkgs/stable/#chap-meta
    description = "Velvetyne typefaces";
    homepage = "http://velvetyne.fr/";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
