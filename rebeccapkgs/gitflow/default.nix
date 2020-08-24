{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) stdenvNoCC fetchFromGitHub;
  inherit (pkgs.gitAndTools) hub git;
in stdenvNoCC.mkDerivation rec {
  pname = "git-hf";
  version = "1.5.4b2";
  src = fetchFromGitHub {
    owner = "hatchcredit";
    repo = "gitflow";
    rev = version;
    sha256 = "14i7illl1lqwngr0hw104sn7snr22sksrbsf4zwmqwsr6c0azj3x";
  };

  patches = [ ./gitflow.patch ];

  shFlags = fetchFromGitHub {
    owner = "nvie";
    repo = "shFlags";
    rev = "1.0.3";
    sha256 = "192sz9gpvq284zziwh05v08shkx4gh2zky401qxfv98iw8qbd7sy";
  };

  buildInputs = [ hub git ];

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    rm -rf shFlags
    cp -r "$shFlags" shFlags
    mkdir -p "$out/bin"
    INSTALL_INTO="$out/bin" bash ./install.sh
  '';
}
