{ fetchFromGitHub, stdenv, glib }:
stdenv.mkDerivation {
  pname = "WhiteSur-gtk-theme";
  version = "2020-11-13";
  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-gtk-theme";
    rev = "3fd4aeb10efbf6008d44f4422f32cf2cf2dda360";
    sha256 = "0y31f2j7w4dsbksva4ggdl3hf07k2szzs71m7hqlv1xqrwzxdgdb";
  };

  nativeBuildInputs = [ glib.dev ];

  dontConfigure = true;
  dontBuild = true;

  # Modified from ./install.sh
  installPhase = ''
    mkdir -p "$out/share/themes"
    bash ./install.sh --dest "$out/share/themes"
  '';
}
