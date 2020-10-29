{ config, pkgs, lib, ... }: {
  imports = [ <nixos-hardware/dell/xps/15-9550> ../imports/desktop.nix ];

  networking.hostName = "cervina";

  # Why is the WiFi card called that!!
  networking.interfaces.wlp59s0.useDHCP = true;

  # Do NOT keep /tmp in RAM because /tmp can get big and this is but a laptop.
  boot.tmpOnTmpfs = false;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # Save our fans / CPU temps.
  boot.kernelModules = [ "coretemp" ];
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  boot.loader.grub.fontSize = 32;

  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-c32n";

  services.xserver.dpi = 216;

  environment.systemPackages = with pkgs;
    [
      light # backlight control
    ];

  hardware.bumblebee.enable = true;
  hardware.pulseaudio.enable = true;
}
