{ fetchFromGitHub, stdenv, lib }:
stdenv.mkDerivation {
  pname = "WhiteSur-cursors";
  version = "2020-08-12";
  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-cursors";
    rev = "1ada17d4e0ad96f5401f5d0f2d917a152f62c556";
    sha256 = "1jzvq2h417ql2chdfy1c4nc4cprc9s9cw19kbxpiy8sqnsc3j5d1";
  };
  dontConfigure = true;
  dontBuild = true;

  # Modified from ./install.sh
  installPhase = ''
    mkdir -p "$out/share/icons"
    cp -r dist "$out/share/icons/WhiteSur-cursors"
  '';
}
