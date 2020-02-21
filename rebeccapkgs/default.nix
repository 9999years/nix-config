{ pkgs ? import <nixpkgs> { }, }:
let
  allPkgs = pkgs // rebeccapkgs;
  callPackage = path: overrides:
    let f = import path;
    in f
    ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  rebeccapkgs = {
    inherit callPackage;
    amazing-marvin = callPackage ./amazing-marvin { };
    appimage = callPackage ./appimage { };
    background-images = callPackage ./background-images { };
    colortest = callPackage ./colortest { };
    glimpse = callPackage ./glimpse { };
    latexdef = callPackage ./latexdef { };
    fontbase = callPackage ./fontbase { };
    mdv = import ./mdv { inherit pkgs; };
    navi = callPackage ./navi { };
    nix-query = callPackage ./nix-query { };
    psftools = callPackage ./psftools { };
    sddm-breeze-rbt-theme = callPackage ./sddm-breeze-rbt-theme { };
    sddm-faces = callPackage ./sddm-faces { };
  };

in rebeccapkgs
