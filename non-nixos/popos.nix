let
  common = import ./common.nix { };
  inherit (common) pkgs list-packages;
  hatchPkgs = import ./hatch.nix { inherit pkgs; };
in list-packages {
  extra = (with pkgs; [ nix ruby man-pages cacert ]) ++ hatchPkgs;
  exclude = [ ];
  sets = sets:
    with sets; [
      misc
      git
      vim
      hardware
      terminals
      network
      files
      text
      manipulation
    ];
  langs = langs: with langs; [ bash nix python rust ];
}
