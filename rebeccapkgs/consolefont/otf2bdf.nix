{ pkgs ? import <nixpkgs> { }, }:
with pkgs;
stdenv.mkDerivation rec {
  name = "otf2bdf";
  version = "3.1";

  meta = with lib.stdenv; { license = licenses.mit; };

  buildInputs = [ freetype ];

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "otf2bdf";
    rev = "cc7f1b5a1220b3a3ffe356e056e6627c64bdf122";
    sha512 =
      "05za0y95q7wb0yv5zggsm8cn7r9gy31iy7hv57vdc8m5ddnw9np9gwx79pv6gdgbs8rkx6qsarfskz4pp5098p0awrls15ny42hfv5v";
  };

  # Fix the make install process, which currently uses a hand-rolled mkdir -p
  # implementation, to use plain-ol mkdir.
  # Also avoid an unused variable warning by not declaring the variable.
  patches = [ ./otf2bdf.patch ];
}
