{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.plasma5;

  rebeccapkgs = import ../rebeccapkgs { inherit pkgs; };

in {
  options.rebecca.plasma5 = {
    enable = mkEnableOption "KDE Plasma 5 display manager";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = lib.mkDefault true;
      dpi = lib.mkDefault 175;

      libinput = {
        enable = true;
        naturalScrolling = true; # Windows-style, baby!
      };

      displayManager = {
        sddm.enable = true;
        defaultSession = "plasma5";
      };

      desktopManager = rec {
        wallpaper = {
          mode = "fill";
          combineScreens = false;
        };
        plasma5.enable = true;
      };
    };

    environment.systemPackages = [
      rebeccapkgs.background-images
      rebeccapkgs.sddm-faces
      # pkgs.libsForQt5.qtstyleplugin-kvantum
    ];
  };
}
