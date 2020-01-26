{
  stdenv ? (import <nixpkgs> {}).stdenv,
}:
stdenv.mkDerivation {
  name = "sddm-my-face";
  version = "1.0.0";
  src = ./becca.face.icon;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    install -D "$src" "$out/share/sddm/faces/$(stripHash $src)"
  '';
}
