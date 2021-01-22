{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.plasma5;

  berrypkgs = import ../berrypkgs { inherit pkgs; };

in {
  options.berry.plasma5 = {
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
      berrypkgs.background-images
      berrypkgs.sddm-faces
      # pkgs.libsForQt5.qtstyleplugin-kvantum
    ];
  };
}
