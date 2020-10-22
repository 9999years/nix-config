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
    atkinson-hyperlegible-font = callPackage ./atkinson-hyperlegible-font { };
    background-images = callPackage ./background-images { };
    colortest = callPackage ./colortest { };
    fontbase = callPackage ./fontbase { };
    gitflow = callPackage ./gitflow { };
    glimpse = callPackage ./glimpse { };
    latexdef = callPackage ./latexdef { };
    mdcat = callPackage ./mdcat { };
    navi = callPackage ./navi { };
    nix-query = callPackage ./nix-query { };
    psftools = callPackage ./psftools { };
    puppy = callPackage ./puppy { };
    sddm-breeze-rbt-theme = callPackage ./sddm-breeze-rbt-theme { };
    sddm-faces = callPackage ./sddm-faces { };
    spdx-tool = callPackage ./spdx-tool { };
    star-tsp100 = callPackage ./star-tsp100 { };
    todoist-gui = callPackage ./todoist-gui { };
    velvetyne-typefaces = callPackage ./velvetyne-typefaces { };
    vscode-cpptools = callPackage ./vscode-cpptools { };
  };

in rebeccapkgs
