{ pkgs ? import <nixpkgs> {}, }:
let py = import ./requirements.nix {};
in py.packages.mdv
