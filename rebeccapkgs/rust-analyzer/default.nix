{ stdenv, fetchurl, ... }:
stdenv.mkDerivation rec {
  name = "rust-analyzer";
  version = "2020-03-16";
  src = fetchurl {
    url =
      "https://github.com/rust-analyzer/rust-analyzer/releases/download/2020-03-23/rust-analyzer-linux";
    sha512 =
      "0shm6wznwm0flriw5p5l62yjh05pz4ncb9dlxv523pk4xagk3airdhkmrvmwdi2s8vhj30pl1rrfv39pwpgiy5wnkllr0fmdmh76dlx";
  };
  unpackPhase = ''
    cp $src $(stripHash $src)
  '';

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin

    chmod +x rust-analyzer-linux
    cp rust-analyzer-linux $out/bin/
    cd $out/bin/
    ln rust-analyzer-linux rust-analyzer
  '';
}
