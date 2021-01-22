{ stdenv ? (import <nixpkgs> { }).stdenv, }:
stdenv.mkDerivation {
  name = "sddm-faces";
  version = "1.1.0";
  srcs = [ ./berry.face.icon ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    for src in $srcs; do
      install -D "$src" "$out/share/sddm/faces/$(stripHash $src)"
    done
  '';
}
