{ config, pkgs, lib, ... }:
let
  background = "${
      import ./pkg/background-images
    }/share/artwork/backgrounds/night-stars.jpg";
in {
  services.xserver = {
    enable = lib.mkDefault true;
    dpi = lib.mkDefault 175;

    libinput = {
      enable = true;
      naturalScrolling = true; # Windows-style, baby!
    };

    displayManager = { lightdm.background = background; };

    desktopManager = rec {
      default = "plasma5";
      wallpaper = {
        mode = "fill";
        combineScreens = false;
      };
      plasma5.enable = true;
    };
  };
}
