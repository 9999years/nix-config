{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.syncthing.desktop;

in {
  options.rebecca.syncthing.desktop = {
    enable = mkEnableOption "Syncthing service (laptops/desktops)";
  };

  config = mkIf cfg.enable {
    services.syncthing = let
      user = "becca";
      inherit (config.users.users."${user}") home;
    in lib.recursiveUpdate (import ../resources/syncthing-base.nix {
      inherit lib;
      dataDir = "${home}/Documents";
    }) {
      inherit user;
      configDir = "${home}/.config/syncthing";
      declarative = {
        folders = { reaction-images.path = "${home}/Pictures/reaction"; };
      };
    };

    environment.systemPackages = with pkgs; [ syncthingtray ];
  };
}
