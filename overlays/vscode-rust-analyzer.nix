{ nixpkgs ? import <nixpkgs> { }, ... }:
let
  inherit (nixpkgs) stdenv fetchFromGitHub;
  overlay = stdenv.mkDerivation {
    name = "rust-analyzer-overlay";
    version = "2020-01-29";

    src = fetchFromGitHub {
      owner = "oxalica";
      repo = "rust-analyzer-overlay";
      rev = "master";
      sha512 =
        "2qvvdj75iwrf1h6k0cjac12f9938rp463acj93lrm0irwd2cfj5wsngn5v2k1spa4b3cwrivbb41kglpi4ym5j65d6rs0l49lhs8fl6";
    };
    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      cp -r source $out
    '';
  };
in import overlay
