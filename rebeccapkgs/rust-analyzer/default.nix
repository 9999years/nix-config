{ stdenv, fetchurl, ... }:
stdenv.mkDerivation rec {
  name = "rust-analyzer";
  version = "2020-03-16";
  src = fetchurl {
    url =
      "https://github.com/rust-analyzer/rust-analyzer/releases/download/2020-03-16/rust-analyzer-linux";
    sha512 =
      "1iwh0203979295nbc9mrhiha0gvm45vrb94v04njf3r2iaflazgl92jwp11kw53m5cjsh2206q5rrhl90xhw9xb1qph9idknz2qkxah";
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
  '';
}
