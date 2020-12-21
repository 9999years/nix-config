{ pkgs ? import <nixpkgs> { } }:
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
    fontbase = callPackage ./fontbase { };
    glimpse = callPackage ./glimpse { };
    init_coc_python = callPackage ./init_coc_python { };
    latexdef = callPackage ./latexdef { };
    mdcat = callPackage ./mdcat { };
    navi = callPackage ./navi { };
    nix-query = callPackage ./nix-query { };
    plasma = callPackage ./plasma { };
    pijul = callPackage ./pijul { };
    psftools = callPackage ./psftools { };
    puppy = callPackage ./puppy { };
    sddm-breeze-rbt-theme = callPackage ./sddm-breeze-rbt-theme { };
    sddm-faces = callPackage ./sddm-faces { };
    spdx-tool = callPackage ./spdx-tool { };
    standardnotes = callPackage ./standardnotes { };
    star-tsp100 = callPackage ./star-tsp100 { };
    typefaces = callPackage ./typefaces { };
    vscode-cpptools = callPackage ./vscode-cpptools { };
    webapp = callPackage ./webapp { };
  };

in rebeccapkgs
