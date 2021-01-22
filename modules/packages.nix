{ config, pkgs, lib, ... }:
let
  inherit (lib)
    recursiveUpdate optionals types mkEnableOption mkMerge mkOption mkIf;

  cfg = config.berry.pkgs;

in {
  options.berry.pkgs = {
    core.enable =
      mkEnableOption "enable <emphasis>only</emphasis> core packages";
    all.enable = mkEnableOption "enable all packages (includes core packages)";
  };

  config = let selections = import ../resources/packages.nix { inherit pkgs; };
  in mkMerge [
    (mkIf cfg.core.enable { environment.systemPackages = selections.core; })
    (mkIf cfg.all.enable { environment.systemPackages = selections.all; })
  ];
}
