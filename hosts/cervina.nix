{ config, pkgs, lib, ... }: {
  imports = [
    ../modules
    <nixos-hardware/dell/xps/15-9550>
    ./cervina-hardware-configuration.nix
  ];

  networking.hostName = "cervina";

  rebecca = {
    desktop.enable = true;
    # laptop.enable = true;
    pkgs.all.enable = true;
  };

  # Why is the WiFi card called that!!
  networking = {
    useDHCP = false;
    interfaces.wlp59s0.useDHCP = true;
  };

  boot = {
    # Do NOT keep /tmp in RAM because /tmp can get big and this is but a laptop.
    tmpOnTmpfs = false;
    kernelModules = [ "coretemp" ];
    loader = {
      grub.fontSize = 32;
      # `null` doesn't seem to work as advertised. we'll wait 2 minutes
      # instead, until i can figure it out.
      timeout = 120;
    };
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
    cpuFreqGovernor = "powersave";
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
