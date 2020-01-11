{ config, pkgs, ... }:
let base = import ./base.nix {};
in {
  networking.interfaces.enp4s1.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  environment.systemPackages = base.packages ++ [
    mdadm  # RAID drives
  ];
}
