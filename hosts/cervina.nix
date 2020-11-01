{ config, pkgs, lib, ... }: {
  imports = [ <nixos-hardware/dell/xps/15-9550> ../imports/desktop.nix ./cervina-hardware-configuration.nix ];

  networking.hostName = "cervina";

  # Why is the WiFi card called that!!
  networking = {
    useDHCP = false;
    interfaces.wlp59s0.useDHCP = true;
  };

  boot = {
    # Do NOT keep /tmp in RAM because /tmp can get big and this is but a laptop.
    tmpOnTmpfs = false;
    kernelModules = [ "coretemp" ];
    loader.grub.fontSize = 32;
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;

    bumblebee.enable = true;
    pulseaudio.enable = true;
  };

  # Save our fans / CPU temps.
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    powertop.enable = true;
  };

  console = {
    packages = with pkgs; [ terminus_font ];
    font = "ter-c32n";
  };

  services.xserver.dpi = 216;

  environment.systemPackages = with pkgs;
    [
      light # backlight control
    ];
}
