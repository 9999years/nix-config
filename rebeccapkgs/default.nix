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
    broot = callPackage ./broot { };
    colortest = callPackage ./colortest { };
    glimpse = callPackage ./glimpse { };
    latexdef = callPackage ./latexdef { };
    fontbase = callPackage ./fontbase { };
    mdcat = callPackage ./mdcat { };
    navi = callPackage ./navi { };
    nix-query = callPackage ./nix-query { };
    psftools = callPackage ./psftools { };
    sddm-breeze-rbt-theme = callPackage ./sddm-breeze-rbt-theme { };
    sddm-faces = callPackage ./sddm-faces { };
    star-tsp100 = callPackage ./star-tsp100 { };
    todoist-gui = callPackage ./todoist-gui { };
    vscode-cpptools = callPackage ./vscode-cpptools { };
  };

in rebeccapkgs
