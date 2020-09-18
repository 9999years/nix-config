{ pkgs ? import <nixpkgs> { overlays = import ./overlays/all.nix; } }:
let
  inherit (pkgs) lib;
  packages = import ./imports/packages.nix { inherit pkgs; };

  manual-exclusions = [ "git" ];

  filter-supported = lib.filter (p:
    builtins.elem builtins.currentSystem (lib.attrByPath [ "meta" "platforms" ]
      (lib.singleton builtins.currentSystem) p));

  filter-manual-exclusions = lib.filter (p:
    !builtins.any
    (name: lib.hasInfix name (lib.attrByPath [ "name" ] p.pname p))
    manual-exclusions);

  extra = with pkgs; [ man-pages cacert ];

in filter-supported (extra ++ filter-manual-exclusions ((with packages.sets;
  git ++ vim ++ terminals ++ network ++ files ++ text ++ manipulation)
  ++ (with packages.langs; bash ++ nix ++ python) ++ (with pkgs; [ nix ruby ])))
