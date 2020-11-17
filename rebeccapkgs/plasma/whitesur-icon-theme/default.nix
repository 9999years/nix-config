{ fetchFromGitHub, stdenv }:
stdenv.mkDerivation {
  pname = "WhiteSur-icon-theme";
  version = "2020-11-13";
  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-icon-theme";
    rev = "ccd98c6ce1c19f626bb9c99934a379063dbaf33e";
    sha256 = "0dszq443xqd861qw79yr3bspbr36fikbzajxys9jqlag0fd1hj41";
  };
  patches = [ ./install.sh.patch ];
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  installPhase = ''
    mkdir -p "$out/share/icons"
    bash ./install.sh --dest "$out/share/icons"
  '';
}
