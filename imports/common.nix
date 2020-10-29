# Configuration common to all hosts; included in both ./desktop.nix and
# ./server.nix.
{ config, pkgs, lib, ... }:
let ssh-keys = import ./ssh-keys.nix;
in {
  boot.tmpOnTmpfs = lib.mkDefault true; # Keep /tmp in RAM
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/New_York";
  users.users = {
    becca = {
      isNormalUser = true;
      description = "Rebecca Turner";
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      uid = 1000;
    };
  };
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
}
