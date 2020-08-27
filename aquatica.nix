{ config, pkgs, lib, ... }: {
  boot.loader.grub.fontSize = 24;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "aquatica";

  networking.interfaces.enp4s1.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  environment.systemPackages = with pkgs;
    [
      mdadm # RAID drives
    ];

  powerManagement.enable = true;

  boot.loader.grub.fontSize = 32;

  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-c32n";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

  services.xserver.dpi = 150;

  # Sound
  hardware.cpu.intel.updateMicrocode = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = false;
  };
  hardware.enableAllFirmware = true;
  boot.extraModprobeConfig = ''
    options snd_hda_intel index=1
  '';
}
