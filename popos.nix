{ pkgs ? import <nixpkgs> { overlays = import ./overlays/all.nix; } }:
let
  inherit (pkgs) lib;
  packages = import ./imports/packages.nix { inherit pkgs; };

  manual-exclusions = [ ];

  filter-supported = lib.filter (p:
    builtins.elem builtins.currentSystem (lib.attrByPath [ "meta" "platforms" ]
      (lib.singleton builtins.currentSystem) p));

  filter-manual-exclusions = lib.filter (p:
    !builtins.any
    (name: lib.hasInfix name (lib.attrByPath [ "name" ] p.pname p))
    manual-exclusions);

  extra = with pkgs; [
    man-pages
    cacert
    rebecca.gitflow # https://github.com/hatchcredit/gitflow
    openjdk14_headless
  ];

in filter-supported (extra ++ filter-manual-exclusions ((with packages.sets;
  misc ++ git ++ vim ++ hardware ++ terminals ++ network ++ files ++ text
  ++ manipulation) ++ (with packages.langs; bash ++ nix ++ python ++ rust)
  ++ (with pkgs; [ nix ruby ])))
