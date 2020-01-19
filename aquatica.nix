{ config, pkgs, lib, ... }:
let base = import ./base.nix { inherit pkgs lib; };
in {
  boot.extraModprobeConfig = ''
    options snd_hda_intel index=1
  '';

  networking.hostName = "aquatica";

  networking.interfaces.enp4s1.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  environment.systemPackages = base.packages ++ (with pkgs; [
    mdadm  # RAID drives
  ]);

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

  services.xserver.dpi = 125;
}
