{ stdenv, python38 }:
stdenv.mkDerivation {
  pname = "init_coc_python";
  version = "1.0.0";
  src = ./init_coc_python.py;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin/
    cp $src $out/bin/init_coc_python.py
    chmod +x $out/bin/init_coc_python.py
  '';
  buildInputs = [ python38 ];

  meta = { description = "Shell-hook utility for Neovim/CoC Python projects"; };
}
