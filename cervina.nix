{ config, pkgs, lib, ... }:
{
  imports = [
      <nixos-hardware/dell/xps/15-9550>
  ];

  networking.hostName = "cervina";

  # We need at least 5.2.2 (IIRC) to get the WiFi drivers.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Why is the WiFi card called that!!
  networking.interfaces.wlp59s0.useDHCP = true;

  services.xserver.dpi = 175;

  environment.systemPackages =
    let base = import ./base.nix { inherit pkgs lib; };
    in base.packages ++ (with pkgs; [
      light # backlight control
    ]);

  hardware.bumblebee.enable = true;
}
