{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.printing;

in {
  options.rebecca.printing = {
    enable = mkEnableOption "physical printer support";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.rebecca.star-tsp100 ];
    };

    hardware.printers.ensurePrinters = [{
      description = "Noah’s Printer (Trouse)";
      name = "noahs-printer";
      location = "Trouse floor 2";
      deviceUri = "socket://192.168.0.144";
      model = "HP/hp-envy_4520_series.ppd.gz";
    }];
  };
}
