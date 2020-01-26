{ config, pkgs, lib, ... }:
let
  backgroundPkg = import ./pkg/background-images {inherit pkgs;};
  background = "${backgroundPkg}/share/wallpapers/night-stars.jpg";
  sddmBreezeTheme = import ./pkg/sddm-breeze-rbt-theme {inherit pkgs background;};
in {
  services.xserver = {
    enable = lib.mkDefault true;
    dpi = lib.mkDefault 175;

    libinput = {
      enable = true;
      naturalScrolling = true; # Windows-style, baby!
    };

    displayManager = {
      sddm = {
        enable = true;
        theme = "${sddmBreezeTheme}/share/sddm/themes/breeze-rbt";
      };
    };

    desktopManager = rec {
      default = "plasma5";
      wallpaper = {
        mode = "fill";
        combineScreens = false;
      };
      plasma5.enable = true;
    };
  };

  environment.systemPackages = [
    (import ./pkg/background-images {inherit pkgs;})
    (import ./pkg/sddm-faces {inherit (pkgs) stdenv;})
    sddmBreezeTheme
  ];
}
