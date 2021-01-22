{ pkgs ? import <nixpkgs> { } }:
let
  allPkgs = pkgs // berrypkgs;
  callPackage = path: overrides:
    let f = import path;
    in f
    ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  berrypkgs = {
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
    misc-gitology = callPackage ./misc-gitology { };
    navi = callPackage ./navi { };
    nix-query = callPackage ./nix-query { };
    notion = callPackage ./notion { };
    pagelabels = callPackage ./pagelabels { };
    pijul = callPackage ./pijul { };
    plasma = callPackage ./plasma { };
    psftools = callPackage ./psftools { };
    sddm-breeze-rbt-theme = callPackage ./sddm-breeze-rbt-theme { };
    sddm-faces = callPackage ./sddm-faces { };
    spdx-tool = callPackage ./spdx-tool { };
    standardnotes = callPackage ./standardnotes { };
    star-tsp100 = callPackage ./star-tsp100 { };
    todoist = callPackage ./todoist { };
    typefaces = callPackage ./typefaces { };
    vscode-cpptools = callPackage ./vscode-cpptools { };
    webapp = callPackage ./webapp { };
    workflowy = callPackage ./workflowy { };
  };

in berrypkgs
