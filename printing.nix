{ config, pkgs, lib, ... }: {
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  hardware.printers.ensurePrinters = [{
    description = "Noah’s Printer (Trouse)";
    name = "noahs-printer";
    location = "Trouse floor 2";
    deviceUri = "socket://192.168.0.144";
    model = "HP/hp-envy_4520_series.ppd.gz";
  }];
}
