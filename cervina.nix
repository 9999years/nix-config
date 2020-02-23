{ config, pkgs, lib, ... }: {
  imports = [ <nixos-hardware/dell/xps/15-9550> ];

  networking.hostName = "cervina";

  # "With kernel version 5.2.2 and linux-firmware 20190717.bf13a71-1, WiFi would be working out of the box."
  # https://wiki.archlinux.org/index.php/Dell_XPS_15_7590#WiFi
  boot.kernelPackages = pkgs.linuxPackages_latest;
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
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  boot.loader.grub.fontSize = 32;

  i18n = {
    consoleFont = "ter-c32n";
    consolePackages = with pkgs; [ terminus_font ];
  };

  services.xserver.dpi = 175;

  environment.systemPackages = with pkgs;
    [
      light # backlight control
    ];

  hardware.bumblebee.enable = true;
  hardware.pulseaudio.enable = true;
}
