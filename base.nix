{ pkgs, lib, ... }:
{
  packages = with import ./packages.nix { inherit pkgs; }; lib.concatLists [
    gui git hardware misc emacs vim

    devtools.terminals devtools.files devtools.text devtools.manipulation
    devtools.misc

    langs.clang langs.dhall langs.go langs.haskell langs.java langs.node
    langs.perl langs.python langs.ruby langs.rust
  ];
}
