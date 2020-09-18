{ pkgs ? import <nixpkgs> { overlays = import ../overlays/all.nix; } }:
let
  inherit (pkgs) lib;
  packages = import ../imports/packages.nix { inherit pkgs; };
in rec {
  filter-manual-exclusions = manual-exclusions:
    lib.filter (p:
      !builtins.any
      (name: lib.hasInfix name (lib.attrByPath [ "name" ] p.pname p))
      manual-exclusions);

  filter-supported = lib.filter (p:
    builtins.elem builtins.currentSystem (lib.attrByPath [ "meta" "platforms" ]
      (lib.singleton builtins.currentSystem) p));

  inherit pkgs;
  inherit packages;

  list-packages = { extra ? [ ], exclude ? [ ], sets, langs, }:
    filter-supported (extra ++ (filter-manual-exclusions exclude
      (lib.flatten ((sets packages.sets) ++ (langs packages.langs)))));
}
