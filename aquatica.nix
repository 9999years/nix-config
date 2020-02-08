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

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

  services.xserver.dpi = 150;

  # Sound
  # sound.enableOSSEmulation = false;
  # hardware.pulseaudio = {
    # enable = true;
    # systemWide = false;
  # };
  hardware.enableAllFirmware = true;
  # boot.extraModprobeConfig = ''
    # options snd_hda_intel index=1
    # options snd slots=snd_hda_intel
  # '';
}
