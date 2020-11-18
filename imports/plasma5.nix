{ config, pkgs, lib, ... }:
let
  rebeccapkgs = import ../rebeccapkgs { inherit pkgs; };
  sddmBreezeTheme = rebeccapkgs.sddm-breeze-rbt-theme.override {
    background =
      "${rebeccapkgs.background-images}/share/wallpapers/night-stars.jpg";
  };
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
    sddmBreezeTheme
    # pkgs.libsForQt5.qtstyleplugin-kvantum
  ];
}
