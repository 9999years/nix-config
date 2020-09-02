{ config, pkgs, lib, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "requienii"; # i love you
  powerManagement.enable = true;
  hardware.enableAllFirmware = true;
}
