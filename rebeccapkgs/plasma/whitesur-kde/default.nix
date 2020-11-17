{ fetchFromGitHub, stdenv, lib }:
stdenv.mkDerivation {
  pname = "WhiteSur-kde";
  version = "2020-11-03";
  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-kde";
    rev = "872f14e8d959f7ea6f43bd2fb24fe13da2e445c0";
    sha256 = "1093qgk1jkscwnl0y2h5nwqf3b0z8qc1ih9b1xvpxly3yzbcqi0w";
  };
  dontConfigure = true;
  dontBuild = true;

  THEME_NAME = "WhiteSur";

  # Modified from ./install.sh
  installPhase = ''
    AURORAE_DIR="$out/share/aurorae/themes"
    SCHEMES_DIR="$out/share/color-schemes"
    PLASMA_DIR="$out/share/plasma/desktoptheme"
    LOOKFEEL_DIR="$out/share/plasma/look-and-feel"
    KVANTUM_DIR="$out/share/Kvantum"
    WALLPAPER_DIR="$out/share/wallpapers"

    mkdir -p "$AURORAE_DIR"
    mkdir -p "$SCHEMES_DIR"
    mkdir -p "$PLASMA_DIR"
    mkdir -p "$LOOKFEEL_DIR"
    mkdir -p "$KVANTUM_DIR"
    mkdir -p "$WALLPAPER_DIR"

    cp -r "aurorae/"*                        "$AURORAE_DIR"
    cp -r "Kvantum/"*                        "$KVANTUM_DIR"
    cp -r "color-schemes/"*                  "$SCHEMES_DIR"
    cp -r "plasma/desktoptheme/$THEME_NAME"* "$PLASMA_DIR"
    cp -r "plasma/desktoptheme/icons"        "$PLASMA_DIR/$THEME_NAME"
    cp -r "plasma/desktoptheme/icons"        "$PLASMA_DIR/$name-alt"
    cp -r "plasma/desktoptheme/icons"        "$PLASMA_DIR/$name-dark"
    cp -r "plasma/look-and-feel/"*           "$LOOKFEEL_DIR"
    cp -r "wallpaper/$THEME_NAME"            "$WALLPAPER_DIR"
  '';
}
