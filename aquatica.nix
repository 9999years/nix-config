{ config, pkgs, lib, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "aquatica";

  networking.interfaces.enp4s1.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    mdadm # RAID drives
    slack
    ripcord
    jetbrains.idea-community
    rebecca.gitflow # https://github.com/hatchcredit/gitflow
    openjdk14-bootstrap
  ];

  powerManagement.enable = true;

  boot.loader.grub.fontSize = 24;

  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-c24n";

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
