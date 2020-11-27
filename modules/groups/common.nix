{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  ssh-keys = import ../resources/ssh-keys.nix;
  cfg = config.rebecca.common;
in {
  options.rebecca.common = {
    enable = (mkEnableOption "configuration for all computers") // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
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
            cervina-yubikey-2020-11-04
            aquatica-2020-10-29
            aquatica-yubikey-2020-11-05
          ];
        };
        becca = {
          isNormalUser = true;
          description = "Rebecca Turner";
          extraGroups = [ "wheel" ];
          uid = 1000;
          openssh.authorizedKeys.keys = with ssh-keys; [
            cervina-2020-08-19
            cervina-yubikey-2020-11-04
            aquatica-2020-10-29
            aquatica-yubikey-2020-11-05
          ];
        };
      };
    };
    programs.fish.enable = true;
    nixpkgs.config.allowUnfree = true;
    nix = rec {
      trustedUsers = [ "root" "becca" ];
      allowedUsers = trustedUsers;

      trustedBinaryCaches = [
        "https://cache.nixos.org"
        "https://all-hies.cachix.org"
        "https://hydra.iohk.io"
      ];
      binaryCaches = trustedBinaryCaches;
      binaryCachePublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
      gc = {
        automatic = true;
        dates = "weekly"; # See `man systemd.time 7`
      };
    };
    system.autoUpgrade = {
      enable = true;
      allowReboot = lib.mkDefault false;
      dates = "14:00"; # daily at 2 PM
    };
    # Try resolving domain names relative to becca.ooo
    networking.search = [ "becca.ooo" ];
  };
}
