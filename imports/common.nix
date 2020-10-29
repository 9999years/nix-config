# Configuration common to all hosts; included in both ./desktop.nix and
# ./server.nix.
{ config, pkgs, lib, ... }:
let ssh-keys = import ../resources/ssh-keys.nix;
in {
  boot.tmpOnTmpfs = lib.mkDefault true; # Keep /tmp in RAM
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/New_York";
  users = {
    defaultUserShell = pkgs.fish;
    users = {
      root = {
        openssh.authorizedKeys.keys = with ssh-keys; [
          cervina-2020-08-19
          aquatica-2020-10-29
        ];
      };
      becca = {
        isNormalUser = true;
        description = "Rebecca Turner";
        extraGroups = [ "wheel" ];
        uid = 1000;
        openssh.authorizedKeys.keys = with ssh-keys; [
          cervina-2020-08-19
          aquatica-2020-10-29
        ];
      };
    };
  };
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
}
