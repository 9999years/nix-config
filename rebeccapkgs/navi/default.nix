{ stdenvNoCC, fetchFromGitHub, makeWrapper, fzf, perl, ncurses, bash, ... }:
stdenvNoCC.mkDerivation rec {
  name = "navi";
  version = "0.18.3";

  src = fetchFromGitHub {
    owner = "denisidoro";
    repo = "navi";
    rev = "v${version}";
    sha512 =
      "1dspks1cj71z76r4lg3c1ylfb8jckwkfvjjl4k7d1k82z4iyqj6hazqh5n158zi50nxdm5i1s0yan4ar0c59znh3qjpfdvnigbq7y2q";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ fzf perl ncurses ];

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/navi

    cp -r cheats $out/share/navi/
    cp -r src $out/share/navi/
    cp navi \
        navi.plugin.bash \
        navi.plugin.fish \
        navi.plugin.zsh \
        $out/share/navi/

    makeWrapper ${bash}/bin/bash $out/bin/navi \
        --argv0 navi \
        --add-flags "$out/share/navi/navi"

    mkdir -p $out/share/fish/conf.d
    cp navi.plugin.fish $out/share/fish/conf.d/
  '';
}
