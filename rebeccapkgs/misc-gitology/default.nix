{ stdenv, fetchFromGitHub, python2, gitFull }:
stdenv.mkDerivation {
  pname = "misc-gitology";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "da-x";
    repo = "misc-gitology";
    rev = "18f5902b0619ab13efd57c1f617c3fe49147f4ca";
    sha256 = "0km5i36pdmklzbfyfblp2l5b29hap7hailh70y9lq6cwjggvk7mp";
  };
  propagatedBuildInputs = [ python2 gitFull ];
  installPhase = ''
    rm -r hooks LICENSE
    mkdir -p $out/bin
    mv * $out/bin
  '';
}
