let
  common = import ./common.nix { };
  inherit (common) pkgs list-packages;
in list-packages {
  extra = [ nix ruby man-pages cacert ];
  exclude = [ "git" ];
  sets = sets: with sets; [ git vim terminals network files text manipulation ];
  langs = langs: with langs; [ bash nix python ];
}
