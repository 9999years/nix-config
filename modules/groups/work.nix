{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkMerge mkEnableOption mkOption mkIf;

  cfg = config.rebecca;

in {
  options.rebecca = {
    work.enable =
      mkEnableOption "configuration for work-owned and work-related computers";
    personal.enable = mkEnableOption "configuration for personal computers";
  };

  config = mkMerge [
    (mkIf cfg.work.enable {
      # TODO
    })
    (mkIf cfg.personal.enable {
      # TODO
    })
  ];
}
