{ pkgs ? import <nixpkgs> { }, }:
let py = import ./requirements.nix { inherit pkgs; };
in py.packages.mdv
