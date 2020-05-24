{ pkgs ? import <nixpkgs> { } }:
let
  unstable = if pkgs ? unstable then pkgs.unstable else pkgs;
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
    mdcat = callPackage ./mdcat { inherit (unstable) rustPlatform; };
    navi = callPackage ./navi { };
    nix-query = callPackage ./nix-query { };
    psftools = callPackage ./psftools { };
    rust-analyzer = callPackage ./rust-analyzer { };
    sddm-breeze-rbt-theme = callPackage ./sddm-breeze-rbt-theme { };
    sddm-faces = callPackage ./sddm-faces { };
    todoist-gui = callPackage ./todoist-gui { };
    vscode-cpptools = callPackage ./vscode-cpptools { };
  };

in rebeccapkgs
